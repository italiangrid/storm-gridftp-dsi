#if defined(linux)
#define _LARGE_FILES
#endif

#include <sys/types.h>
#include <dirent.h>
#include <string.h>

#include "globus_gridftp_server.h"
#include "dsi_StoRM.h"

#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

#include <zlib.h>
#include <attr/xattr.h>

#define  CA_MAXCKSUMLEN 32
#define  CA_MAXCKSUMNAMELEN 15

static globus_version_t local_version = {
    0, /* major version number */
    1, /* minor version number */
    1157544130,
    0 /* branch ID */
};

 
static globus_result_t globus_l_gfs_make_error(const char *msg) {
    char *err_str;
    globus_result_t result;
	
    GlobusGFSName(globus_l_gfs_make_error);

    err_str = globus_common_create_string("%s error: %s", msg,  strerror(errno));
    result = GlobusGFSErrorGeneric(err_str);

    globus_free(err_str);
    return result;
}

void fill_stat_array(globus_gfs_stat_t * filestat, struct stat64 statbuf, char *name) {
    filestat->mode = statbuf.st_mode;;
    filestat->nlink = statbuf.st_nlink;
    filestat->uid = statbuf.st_uid;
    filestat->gid = statbuf.st_gid;
    filestat->size = statbuf.st_size;

    filestat->mtime = statbuf.st_mtime;
    filestat->atime = statbuf.st_atime;
    filestat->ctime = statbuf.st_ctime;

    filestat->dev = statbuf.st_dev;
    filestat->ino = statbuf.st_ino;
    filestat->name = strdup(name); 
}

void free_stat_array(globus_gfs_stat_t * filestat,int count) {
    int i;
    for(i=0;i<count;i++) free(filestat[i].name);
}

void free_checksum_list(checksum_block_list_t *checksum_list) {
    checksum_block_list_t *             checksum_list_p;
    checksum_block_list_t *             checksum_list_pp;
    checksum_list_p=checksum_list;
        
    while(checksum_list_p->next!=NULL) {
      checksum_list_pp=checksum_list_p->next;
      globus_free(checksum_list_p);
      checksum_list_p=checksum_list_pp;
    }
    globus_free(checksum_list_p);
}

int offsetComparison(const void *first, const void *second) {
  checksum_block_list_t** f = (checksum_block_list_t**)first;
  checksum_block_list_t** s = (checksum_block_list_t**)second;
  long long int diff = (*f)->offset - (*s)->offset;
  if(diff==0) return 0;
  if(diff>0) return 1;
  return -1;
}


#define BASE 65521UL
#define MOD(a) a %= BASE

unsigned long  adler32_combine_(unsigned int adler1, unsigned int adler2, globus_off_t len2) {
    unsigned int sum1;
    unsigned int sum2;
    unsigned int rem;

    rem = (unsigned int)(len2 % BASE);
    sum1 = adler1 & 0xffff;
    sum2 = rem * sum1;
    MOD(sum2);
    sum1 += (adler2 & 0xffff) + BASE - 1;
    sum2 += ((adler1 >> 16) & 0xffff) + ((adler2 >> 16) & 0xffff) + BASE - rem;
    if (sum1 >= BASE) sum1 -= BASE;
    if (sum1 >= BASE) sum1 -= BASE;
    if (sum2 >= (BASE << 1)) sum2 -= (BASE << 1);
    if (sum2 >= BASE) sum2 -= BASE;
    return sum1 | (sum2 << 16);
}

/*************************************************************************
 *  start
 *  -----
 *  This function is called when a new session is initialized, ie a user 
 *  connectes to the server.  This hook gives the dsi an oppertunity to
 *  set internal state that will be threaded through to all other
 *  function calls associated with this session.  And an oppertunity to
 *  reject the user.
 *
 *  finished_info.info.session.session_arg should be set to an DSI
 *  defined data structure.  This pointer will be passed as the void *
 *  user_arg parameter to all other interface functions.
 * 
 *  NOTE: at nice wrapper function should exist that hides the details 
 *        of the finished_info structure, but it currently does not.  
 *        The DSI developer should jsut follow this template for now
 ************************************************************************/
static void globus_l_gfs_StoRM_start(globus_gfs_operation_t op, globus_gfs_session_info_t *session_info) {
    globus_l_gfs_StoRM_handle_t *StoRM_handle;
    globus_gfs_finished_info_t finished_info;
    char *p;
    char *func="globus_l_gfs_StoRM_start";
    
    GlobusGFSName(globus_l_gfs_StoRM_start);

    StoRM_handle = (globus_l_gfs_StoRM_handle_t *)
        globus_malloc(sizeof(globus_l_gfs_StoRM_handle_t));

        
    globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: started, uid: %u, gid: %u\n",func, getuid(),getgid());
    globus_mutex_init(&StoRM_handle->mutex,NULL);
    
    memset(&finished_info, '\0', sizeof(globus_gfs_finished_info_t));
    finished_info.type = GLOBUS_GFS_OP_SESSION_START;
    finished_info.result = GLOBUS_SUCCESS;
    finished_info.info.session.session_arg = StoRM_handle;
    finished_info.info.session.username = session_info->username;
    finished_info.info.session.home_dir = NULL;

    StoRM_handle->checksum_list=NULL;
    StoRM_handle->checksum_list_p=NULL;
    
    StoRM_handle->useCksum=1;
    if ((p = getenv ("STORM_USE_CKSUM")) !=NULL) 
        if (0 == strcasecmp(p, "no")) StoRM_handle->useCksum=0;     
    if (StoRM_handle->useCksum) globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: STORM_USE_CKSUM=YES\n",func);
    else globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: STORM_USE_CKSUM=NO\n",func);
    
    globus_gridftp_server_operation_finished(op, GLOBUS_SUCCESS, &finished_info);
}

/*************************************************************************
 *  destroy
 *  -------
 *  This is called when a session ends, ie client quits or disconnects.
 *  The dsi should clean up all memory they associated wit the session
 *  here. 
 ************************************************************************/
static void globus_l_gfs_StoRM_destroy(void *user_arg) {
    globus_l_gfs_StoRM_handle_t *StoRM_handle;

    StoRM_handle = (globus_l_gfs_StoRM_handle_t *) user_arg;
    
    globus_mutex_destroy(&StoRM_handle->mutex);
    
    globus_free(StoRM_handle);
}

/*************************************************************************
 *  stat
 *  ----
 *  This interface function is called whenever the server needs 
 *  information about a given file or resource.  It is called then an
 *  LIST is sent by the client, when the server needs to verify that 
 *  a file exists and has the proper permissions, etc.
 ************************************************************************/
static void globus_l_gfs_StoRM_stat(globus_gfs_operation_t op, globus_gfs_stat_info_t *stat_info, void *user_arg) {
    globus_gfs_stat_t *stat_array;
    int stat_count;
    globus_l_gfs_StoRM_handle_t *StoRM_handle;
    
    char *func="globus_l_gfs_StoRM_stat";
    struct stat64 statbuf;
    int status=0;
    globus_result_t result;
    char *pathname;
    
    GlobusGFSName(globus_l_gfs_StoRM_stat);

    StoRM_handle = (globus_l_gfs_StoRM_handle_t *) user_arg;
    
    pathname = strdup(stat_info->pathname);
        
    globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: pathname: %s\n",func,pathname);
    
    status=stat64(pathname,&statbuf);
    if(status!=0) {
        result=globus_l_gfs_make_error("fstat64");
        globus_gridftp_server_finished_stat(op,result,NULL, 0);
        free(pathname);
        return;
    }
	
    globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: stat for the file: %s\n",func,pathname);
    stat_array = (globus_gfs_stat_t *) globus_calloc(1, sizeof(globus_gfs_stat_t));
    if(stat_array==NULL) {
       result=GlobusGFSErrorGeneric("error: memory allocation failed");
       globus_gridftp_server_finished_stat(op,result,NULL, 0);
       free(pathname);
       return;
    }
    stat_count=1;
    fill_stat_array(&(stat_array[0]),statbuf,pathname);
    globus_gridftp_server_finished_stat(op, GLOBUS_SUCCESS, stat_array, stat_count);
    free_stat_array(stat_array, stat_count);
    globus_free(stat_array);
    free(pathname);
    return;
}

/*************************************************************************
 *  command
 *  -------
 *  This interface function is called when the client sends a 'command'.
 *  commands are such things as mkdir, remdir, delete.  The complete
 *  enumeration is below.
 *
 *  To determine which command is being requested look at:
 *      cmd_info->command
 *
 *      GLOBUS_GFS_CMD_MKD = 1,
 *      GLOBUS_GFS_CMD_RMD,
 *      GLOBUS_GFS_CMD_DELE,
 *      GLOBUS_GFS_CMD_RNTO,
 *      GLOBUS_GFS_CMD_RNFR,
 *      GLOBUS_GFS_CMD_CKSM,
 *      GLOBUS_GFS_CMD_SITE_CHMOD,
 *      GLOBUS_GFS_CMD_SITE_DSI
 ************************************************************************/
static void globus_l_gfs_StoRM_command(globus_gfs_operation_t op, globus_gfs_command_info_t *cmd_info, void *user_arg) {
    globus_l_gfs_StoRM_handle_t *     StoRM_handle;
    globus_result_t                     result;
    
    
    GlobusGFSName(globus_l_gfs_StoRM_command);
    StoRM_handle = (globus_l_gfs_StoRM_handle_t *) user_arg;

    result=GlobusGFSErrorGeneric("error: commands denied");
    globus_gridftp_server_finished_command(op, result, GLOBUS_NULL);
    return;
}
 
static void globus_l_gfs_file_net_read_cb(globus_gfs_operation_t op, globus_result_t result, globus_byte_t *buffer, globus_size_t nbytes, globus_off_t offset, globus_bool_t eof, void *user_arg) {
    globus_off_t start_offset;
    globus_l_gfs_StoRM_handle_t *StoRM_handle;
    globus_size_t bytes_written;
    unsigned long adler;
    checksum_block_list_t **checksum_array;
    checksum_block_list_t *checksum_list_pp;
    unsigned long index;
    unsigned long i;
    unsigned long file_checksum;
    char ckSumbuf[CA_MAXCKSUMLEN+1]; 
    char *func="globus_l_gfs_file_net_read_cb";
        
    StoRM_handle = (globus_l_gfs_StoRM_handle_t *) user_arg;
        
    globus_mutex_lock(&StoRM_handle->mutex);

    if(eof) StoRM_handle->done = GLOBUS_TRUE;
    StoRM_handle->outstanding--;
    if(result != GLOBUS_SUCCESS) {
        StoRM_handle->cached_res = result;
        StoRM_handle->done = GLOBUS_TRUE;
    } else if(nbytes > 0) {
      start_offset = lseek64(StoRM_handle->fd, offset, SEEK_SET);
      if(start_offset != offset) {
         StoRM_handle->cached_res = globus_l_gfs_make_error("seek");
         StoRM_handle->done = GLOBUS_TRUE;
      } else {
          bytes_written = write(StoRM_handle->fd, buffer, nbytes);
          if (StoRM_handle->useCksum) {
              adler = adler32(0L, Z_NULL, 0);
              adler = adler32(adler, buffer, nbytes);
                    
              StoRM_handle->checksum_list_p->next=(checksum_block_list_t *)globus_malloc(sizeof(checksum_block_list_t));
                    
              if (StoRM_handle->checksum_list_p->next==NULL) {
                  StoRM_handle->cached_res = GLOBUS_FAILURE;
                  globus_gfs_log_message(GLOBUS_GFS_LOG_ERR,"%s: malloc error \n",func);
                  StoRM_handle->done = GLOBUS_TRUE;
                  globus_mutex_unlock(&StoRM_handle->mutex);
                  return;
              }
              StoRM_handle->checksum_list_p->next->next=NULL;
              StoRM_handle->checksum_list_p->offset=offset;
              StoRM_handle->checksum_list_p->size=bytes_written;
              StoRM_handle->checksum_list_p->csumvalue=adler;
              StoRM_handle->checksum_list_p=StoRM_handle->checksum_list_p->next;
              StoRM_handle->number_of_blocks++;
          }
          if(bytes_written < nbytes) {
              if(bytes_written >= 0) errno = ENOSPC;
              StoRM_handle->cached_res = globus_l_gfs_make_error("write");
              StoRM_handle->done = GLOBUS_TRUE;
              free_checksum_list(StoRM_handle->checksum_list);
          } else globus_gridftp_server_update_bytes_written(op,offset,nbytes);
       }
    }

    globus_free(buffer);
    if(!StoRM_handle->done) globus_l_gfs_StoRM_read_from_net(StoRM_handle);
    else if(StoRM_handle->outstanding == 0) {
       if (StoRM_handle->useCksum) {
           checksum_array=(checksum_block_list_t**)globus_calloc(StoRM_handle->number_of_blocks,sizeof(checksum_block_list_t*));
           if (checksum_array==NULL) {
               free_checksum_list(StoRM_handle->checksum_list);
               StoRM_handle->cached_res = GLOBUS_FAILURE;
               globus_gfs_log_message(GLOBUS_GFS_LOG_ERR,"%s: malloc error \n",func);
               StoRM_handle->done = GLOBUS_TRUE;
               close(StoRM_handle->fd);
               globus_mutex_unlock(&StoRM_handle->mutex);
               return;
           }
           checksum_list_pp=StoRM_handle->checksum_list;
           index = 0;
           while (checksum_list_pp->next != NULL) {
               checksum_array[index] = checksum_list_pp;
               checksum_list_pp=checksum_list_pp->next;
               index++;
           }
           qsort(checksum_array, index, sizeof(checksum_block_list_t*), offsetComparison);
           file_checksum=checksum_array[0]->csumvalue;
           for (i=1;i<StoRM_handle->number_of_blocks;i++) {
              file_checksum=adler32_combine_(file_checksum,checksum_array[i]->csumvalue,checksum_array[i]->size);
           }
           globus_free(checksum_array);
           free_checksum_list(StoRM_handle->checksum_list);
           sprintf(ckSumbuf,"%08lx",file_checksum);

           fsetxattr(StoRM_handle->fd,"user.storm.checksum.adler32",ckSumbuf,strlen(ckSumbuf),0);
        }
        close(StoRM_handle->fd);
			
        globus_gridftp_server_finished_transfer(op, StoRM_handle->cached_res);
    }
    globus_mutex_unlock(&StoRM_handle->mutex);
}
 
   
static void globus_l_gfs_StoRM_read_from_net(globus_l_gfs_StoRM_handle_t *StoRM_handle) {
    globus_byte_t *buffer;
    globus_result_t result;
    char *func="globus_l_gfs_StoRM_read_from_net";

    GlobusGFSName(globus_l_gfs_StoRM_read_from_net);
	
    globus_gridftp_server_get_optimal_concurrency(StoRM_handle->op, &StoRM_handle->optimal_count);
	
    while(StoRM_handle->outstanding < StoRM_handle->optimal_count) {
        buffer=globus_malloc(StoRM_handle->block_size);
        if (buffer == NULL) {
            result = GlobusGFSErrorGeneric("error: globus malloc failed");
            StoRM_handle->cached_res = result;
            StoRM_handle->done = GLOBUS_TRUE;
            if(StoRM_handle->outstanding == 0) {
               close(StoRM_handle->fd);
               globus_gridftp_server_finished_transfer(StoRM_handle->op, StoRM_handle->cached_res);
            }
            return;
         }
         result=globus_gridftp_server_register_read(StoRM_handle->op, buffer, StoRM_handle->block_size, globus_l_gfs_file_net_read_cb, StoRM_handle);

         if(result != GLOBUS_SUCCESS)  {
             globus_gfs_log_message(GLOBUS_GFS_LOG_ERR,"%s: register read has finished with a bad result \n",func);
             globus_free(buffer);
             StoRM_handle->cached_res = result;
             StoRM_handle->done = GLOBUS_TRUE;
             if(StoRM_handle->outstanding == 0) {
                close(StoRM_handle->fd);
                globus_gridftp_server_finished_transfer(StoRM_handle->op, StoRM_handle->cached_res);
             }
             return;
         }
         StoRM_handle->outstanding++;
     }
}

/*************************************************************************
 *  recv
 *  ----
 *  This interface function is called when the client requests that a
 *  file be transfered to the server.
 *
 *  To receive a file the following functions will be used in roughly
 *  the presented order.  They are doced in more detail with the
 *  gridftp server documentation.
 *
 *      globus_gridftp_server_begin_transfer();
 *      globus_gridftp_server_register_read();
 *      globus_gridftp_server_finished_transfer();
 *
 ************************************************************************/

static void globus_l_gfs_StoRM_recv(globus_gfs_operation_t op, globus_gfs_transfer_info_t *transfer_info, void *user_arg) {
    globus_l_gfs_StoRM_handle_t *StoRM_handle;
    
    globus_result_t result;
    char *func="globus_l_gfs_StoRM_recv";
    char *pathname;
    int flags;
    
    GlobusGFSName(globus_l_gfs_StoRM_recv);
    StoRM_handle = (globus_l_gfs_StoRM_handle_t *) user_arg;
   
    globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: started\n",func);
    
    pathname=strdup(transfer_info->pathname);

    if(pathname==NULL) {
        result=GlobusGFSErrorGeneric("error: strdup failed");
        globus_gridftp_server_finished_transfer(op, result);
        return;
    }
    globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: pathname: %s \n",func,pathname);
    
    flags = O_WRONLY | O_CREAT;
    if(transfer_info->truncate) flags |= O_TRUNC;
    
    StoRM_handle->fd = open64(pathname, flags, 0644);
    
    if(StoRM_handle->fd < 0) {
        result=globus_l_gfs_make_error("open/create");
        free(pathname);
        globus_gridftp_server_finished_transfer(op, result);
        return;
    }
	    
   StoRM_handle->cached_res = GLOBUS_SUCCESS;
   StoRM_handle->outstanding = 0;
   StoRM_handle->done = GLOBUS_FALSE;
   StoRM_handle->blk_length = 0;
   StoRM_handle->blk_offset = 0;
   StoRM_handle->op = op;
   
   globus_gridftp_server_get_block_size(op, &StoRM_handle->block_size);
   globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: block size: %ld\n",func,StoRM_handle->block_size);
   
   StoRM_handle->checksum_list=(checksum_block_list_t *)globus_malloc(sizeof(checksum_block_list_t));
   if (StoRM_handle->checksum_list==NULL) {
       globus_gfs_log_message(GLOBUS_GFS_LOG_ERR,"%s: malloc error \n",func);
       globus_gridftp_server_finished_transfer(op, GLOBUS_FAILURE);
       return;
   }
   StoRM_handle->checksum_list->next=NULL;
   StoRM_handle->checksum_list_p=StoRM_handle->checksum_list;
   StoRM_handle->number_of_blocks=0;
   
   globus_gridftp_server_begin_transfer(op, 0, StoRM_handle);
   
   globus_mutex_lock(&StoRM_handle->mutex);
      
   globus_l_gfs_StoRM_read_from_net(StoRM_handle);
      
   globus_mutex_unlock(&StoRM_handle->mutex);

   free(pathname); 

   globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: finished\n",func);

   return;
}

/*************************************************************************
 *  send
 *  ----
 *  This interface function is called when the client requests to receive
 *  a file from the server.
 *
 *  To send a file to the client the following functions will be used in roughly
 *  the presented order.  They are doced in more detail with the
 *  gridftp server documentation.
 *
 *      globus_gridftp_server_begin_transfer();
 *      globus_gridftp_server_register_write();
 *      globus_gridftp_server_finished_transfer();
 *
 ************************************************************************/
static void globus_l_gfs_StoRM_send(globus_gfs_operation_t op, globus_gfs_transfer_info_t *transfer_info, void *user_arg) {
    globus_l_gfs_StoRM_handle_t *StoRM_handle;
    char *func="globus_l_gfs_StoRM_send";
    char *pathname;
    int i;
    globus_bool_t done;
    globus_result_t result;
    
    GlobusGFSName(globus_l_gfs_StoRM_send);
    StoRM_handle = (globus_l_gfs_StoRM_handle_t *) user_arg;
    globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: started\n",func);
    
    
    pathname=strdup(transfer_info->pathname);
    if (pathname == NULL) {
        result = GlobusGFSErrorGeneric("error: strdup failed");
        globus_gridftp_server_finished_transfer(op, result);
        return;
    }
    
    globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: pathname: %s\n",func,pathname);
    StoRM_handle->fd = open64(pathname, O_RDONLY, 0);
    
    if(StoRM_handle->fd < 0) {
       result = globus_l_gfs_make_error("open");
       free(pathname);
       globus_gridftp_server_finished_transfer(op, result);
       return;
    }
    
    StoRM_handle->cached_res = GLOBUS_SUCCESS;
    StoRM_handle->outstanding = 0;
    StoRM_handle->done = GLOBUS_FALSE;
    StoRM_handle->blk_length = 0;
    StoRM_handle->blk_offset = 0;
    StoRM_handle->op = op;
    
    globus_gridftp_server_get_optimal_concurrency(op, &StoRM_handle->optimal_count);
    globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: optimal_concurrency: %u\n",func,StoRM_handle->optimal_count);
    
    globus_gridftp_server_get_block_size(op, &StoRM_handle->block_size);
    globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: block_size: %ld\n",func,StoRM_handle->block_size);
    
    StoRM_handle->number_of_blocks=0;
    
    globus_gridftp_server_begin_transfer(op, 0, StoRM_handle);
    done = GLOBUS_FALSE;
    globus_mutex_lock(&StoRM_handle->mutex);

    for(i=0; i<StoRM_handle->optimal_count && !done; i++) {
        done = globus_l_gfs_StoRM_send_next_to_client(StoRM_handle);
    }

    globus_mutex_unlock(&StoRM_handle->mutex);
    free(pathname);
    globus_gfs_log_message(GLOBUS_GFS_LOG_DUMP,"%s: finished\n",func);
}

static globus_bool_t globus_l_gfs_StoRM_send_next_to_client(globus_l_gfs_StoRM_handle_t *StoRM_handle) {
    globus_result_t result;
    globus_result_t res;
    globus_off_t read_length;
    globus_off_t nbread;
    globus_off_t start_offset;
    globus_byte_t *buffer;
    char *func = "globus_l_gfs_StoRM_send_next_to_client";

    GlobusGFSName(globus_l_gfs_StoRM_send_next_to_client);
        
    if (StoRM_handle->blk_length == 0) {
        globus_gridftp_server_get_read_range(StoRM_handle->op, &StoRM_handle->blk_offset, &StoRM_handle->blk_length);
        if(StoRM_handle->blk_length == 0) {
            result = GLOBUS_SUCCESS;
            close(StoRM_handle->fd);
	    StoRM_handle->cached_res = result;
            StoRM_handle->done = GLOBUS_TRUE;
            if (StoRM_handle->outstanding == 0) globus_gridftp_server_finished_transfer(StoRM_handle->op, StoRM_handle->cached_res);
            return StoRM_handle->done;
        }
     }

     if(StoRM_handle->blk_length == -1 || StoRM_handle->blk_length > StoRM_handle->block_size) read_length = StoRM_handle->block_size;
     else read_length = StoRM_handle->blk_length;
	
     start_offset = lseek64(StoRM_handle->fd, StoRM_handle->blk_offset, SEEK_SET);
     if(start_offset != StoRM_handle->blk_offset) {
         result = globus_l_gfs_make_error("seek");
         close(StoRM_handle->fd);
         StoRM_handle->cached_res = result;
         StoRM_handle->done = GLOBUS_TRUE;
         if (StoRM_handle->outstanding == 0) globus_gridftp_server_finished_transfer(StoRM_handle->op, StoRM_handle->cached_res);
         return StoRM_handle->done;
     }
	
     buffer = globus_malloc(read_length);
     if(buffer == NULL) {
         result = GlobusGFSErrorGeneric("error: malloc failed");
         close(StoRM_handle->fd);
	 StoRM_handle->cached_res = result;
         StoRM_handle->done = GLOBUS_TRUE;
         if (StoRM_handle->outstanding == 0) globus_gridftp_server_finished_transfer(StoRM_handle->op, StoRM_handle->cached_res);
	 return StoRM_handle->done;
     }
	
     nbread = read(StoRM_handle->fd, buffer, read_length);

     if(nbread == 0) {
         result = GLOBUS_SUCCESS; 
         globus_free(buffer);
		
         close(StoRM_handle->fd);
        
	 StoRM_handle->cached_res = result;
         StoRM_handle->done = GLOBUS_TRUE;
         if (StoRM_handle->outstanding == 0) { 
            globus_gridftp_server_finished_transfer(StoRM_handle->op, StoRM_handle->cached_res);
         }
         globus_gfs_log_message(GLOBUS_GFS_LOG_INFO,"%s: finished (eof)\n",func);
         return StoRM_handle->done;
     }
     if(nbread < 0) {
        result = globus_l_gfs_make_error("read"); 
        globus_free(buffer);
        close(StoRM_handle->fd);
        StoRM_handle->cached_res = result;
        StoRM_handle->done = GLOBUS_TRUE;
        if (StoRM_handle->outstanding == 0) { 
           globus_gridftp_server_finished_transfer(StoRM_handle->op, StoRM_handle->cached_res);
        }
        globus_gfs_log_message(GLOBUS_GFS_LOG_ERR,"%s: finished (error)\n",func);
        return StoRM_handle->done;

     }
	
     if(read_length>=nbread) {
        StoRM_handle->optimal_count--;
     }
     read_length = nbread;
	
     if(StoRM_handle->blk_length != -1) StoRM_handle->blk_length -= read_length;

     res = globus_gridftp_server_register_write(StoRM_handle->op, buffer, read_length, StoRM_handle->blk_offset, -1, globus_l_gfs_net_write_cb, StoRM_handle);
	
     StoRM_handle->blk_offset += read_length;
	
     if(res != GLOBUS_SUCCESS) {
         globus_free(buffer);
         close(StoRM_handle->fd);
         StoRM_handle->cached_res = res;
         StoRM_handle->done = GLOBUS_TRUE;
         if (StoRM_handle->outstanding == 0) globus_gridftp_server_finished_transfer(StoRM_handle->op, StoRM_handle->cached_res);
         return StoRM_handle->done;
     }

     StoRM_handle->outstanding++;
     return GLOBUS_FALSE;
}	


static void globus_l_gfs_net_write_cb(globus_gfs_operation_t op, globus_result_t result, globus_byte_t *buffer, globus_size_t nbytes, void *user_arg) {
    globus_l_gfs_StoRM_handle_t *StoRM_handle;
    char *func="globus_l_gfs_net_write_cb";

    StoRM_handle = (globus_l_gfs_StoRM_handle_t *) user_arg;
	
    globus_free(buffer); 
    globus_mutex_lock(&StoRM_handle->mutex);

    StoRM_handle->outstanding--;
    if(result != GLOBUS_SUCCESS) {
        StoRM_handle->cached_res = result;
        StoRM_handle->done = GLOBUS_TRUE;
    }
    if(!StoRM_handle->done)  globus_l_gfs_StoRM_send_next_to_client(StoRM_handle);
    else if (StoRM_handle->outstanding == 0) {
       close(StoRM_handle->fd);
       globus_gfs_log_message(GLOBUS_GFS_LOG_INFO,"%s: finished transfer\n",func);
       globus_gridftp_server_finished_transfer(op, StoRM_handle->cached_res);
    }
    globus_mutex_unlock(&StoRM_handle->mutex);
}


static int globus_l_gfs_StoRM_activate(void);

static int globus_l_gfs_StoRM_deactivate(void);

static globus_gfs_storage_iface_t globus_l_gfs_StoRM_dsi_iface = {
    GLOBUS_GFS_DSI_DESCRIPTOR_BLOCKING | GLOBUS_GFS_DSI_DESCRIPTOR_SENDER,
    globus_l_gfs_StoRM_start,
    globus_l_gfs_StoRM_destroy,
    NULL, /* list */
    globus_l_gfs_StoRM_send,
    globus_l_gfs_StoRM_recv,
    NULL, /* trev */
    NULL, /* active */
    NULL, /* passive */
    NULL, /* data destroy */
    globus_l_gfs_StoRM_command, 
    globus_l_gfs_StoRM_stat,
    NULL,
    NULL
};


GlobusExtensionDefineModule(globus_gridftp_server_StoRM) = {
    "globus_gridftp_server_StoRM",
    globus_l_gfs_StoRM_activate,
    globus_l_gfs_StoRM_deactivate,
    NULL,
    NULL,
    &local_version
};

static int globus_l_gfs_StoRM_activate(void) {
    globus_extension_registry_add(GLOBUS_GFS_DSI_REGISTRY, "StoRM", GlobusExtensionMyModule(globus_gridftp_server_StoRM), &globus_l_gfs_StoRM_dsi_iface);
    
    return 0;
}

static int globus_l_gfs_StoRM_deactivate(void) {
    globus_extension_registry_remove(
    GLOBUS_GFS_DSI_REGISTRY, "StoRM");
    return 0;
}

