package railo.commons.io.log.log4j.appender;

import org.apache.log4j.*;
import java.io.IOException;
import java.io.Writer;
import java.io.File;
import java.nio.charset.Charset;

import org.apache.log4j.helpers.OptionConverter;
import org.apache.log4j.helpers.LogLog;
import org.apache.log4j.helpers.CountingQuietWriter;
import org.apache.log4j.spi.LoggingEvent;

import railo.print;
import railo.commons.io.log.log4j.layout.ClassicLayout;
import railo.commons.io.res.Resource;

public class RollingResourceAppender extends ResourceAppender {
	
	
	private static final long MAX_FILE_SIZE = 10*1024*1024;
	private static final int MAX_BACKUP_INDEX = 10;

	protected final long maxFileSize;
	protected int  maxBackupIndex;
	
	private long nextRollover = 0;


  /**
     Instantiate a FileAppender and open the file designated by
    <code>filename</code>. The opened filename will become the output
    destination for this appender.

    <p>The file will be appended to.  */
  public RollingResourceAppender(Layout layout, Resource res,Charset charset) throws IOException {
    this(layout, res,charset, true,MAX_FILE_SIZE,MAX_BACKUP_INDEX);
  }


  /**
    Instantiate a RollingFileAppender and open the file designated by
    <code>filename</code>. The opened filename will become the ouput
    destination for this appender.

    <p>If the <code>append</code> parameter is true, the file will be
    appended to. Otherwise, the file desginated by
    <code>filename</code> will be truncated before being opened.
  */
  public RollingResourceAppender(Layout layout, Resource res,Charset charset, boolean append) throws IOException {
    this(layout, res,charset, append,MAX_FILE_SIZE,MAX_BACKUP_INDEX);
  }
  

  /**
    Instantiate a RollingFileAppender and open the file designated by
    <code>filename</code>. The opened filename will become the ouput
    destination for this appender.

    <p>If the <code>append</code> parameter is true, the file will be
    appended to. Otherwise, the file desginated by
    <code>filename</code> will be truncated before being opened.
  */
  public RollingResourceAppender(Layout layout, Resource res,Charset charset, boolean append, long maxFileSize,int maxBackupIndex) throws IOException {
    super(layout, res,charset, append);
    this.maxFileSize=maxFileSize;
    this.maxBackupIndex=maxBackupIndex;
  }
  

/**
     Returns the value of the <b>MaxBackupIndex</b> option.
   */
  public int getMaxBackupIndex() {
    return maxBackupIndex;
  }

 /**
    Get the maximum size that the output file is allowed to reach
    before being rolled over to backup files.

    @since 1.1
 */
  public long getMaximumFileSize() {
    return maxFileSize;
  }

  /**
     Implements the usual roll over behaviour.

     <p>If <code>MaxBackupIndex</code> is positive, then files
     {<code>File.1</code>, ..., <code>File.MaxBackupIndex -1</code>}
     are renamed to {<code>File.2</code>, ...,
     <code>File.MaxBackupIndex</code>}. Moreover, <code>File</code> is
     renamed <code>File.1</code> and closed. A new <code>File</code> is
     created to receive further log output.

     <p>If <code>MaxBackupIndex</code> is equal to zero, then the
     <code>File</code> is truncated with no backup files created.

   */
	public void rollOver() {
		Resource target;
		Resource file;

		if (qw != null) {
			long size = ((CountingQuietWriter) qw).getCount();
			LogLog.debug("rolling over count=" + size);
			//   if operation fails, do not roll again until
			//   maxFileSize more bytes are written
			nextRollover = size + maxFileSize;
		}
		LogLog.debug("maxBackupIndex="+maxBackupIndex);

		boolean renameSucceeded = true;
		Resource parent = res.getParentResource();
		
		// If maxBackups <= 0, then there is no file renaming to be done.
		if(maxBackupIndex > 0) {
			// Delete the oldest file, to keep Windows happy.
			file = parent.getRealResource(res.getName()+"."+maxBackupIndex+".bak");

			if (file.exists()) renameSucceeded = file.delete();

			// Map {(maxBackupIndex - 1), ..., 2, 1} to {maxBackupIndex, ..., 3, 2}
			for (int i = maxBackupIndex - 1; i >= 1 && renameSucceeded; i--) {
				file = parent.getRealResource(res.getName()+"."+i+".bak");
				if (file.exists()) {
					target = parent.getRealResource(res.getName()+"."+(i + 1)+".bak");
					LogLog.debug("Renaming file " + file + " to " + target);
					renameSucceeded = file.renameTo(target);
				}
			}

			if(renameSucceeded) {
				// Rename fileName to fileName.1
				target = parent.getRealResource(res.getName()+".1.bak");

				this.closeFile(); // keep windows happy.

				file = res;
				LogLog.debug("Renaming file " + file + " to " + target);
				renameSucceeded = file.renameTo(target);

				//   if file rename failed, reopen file with append = true

				if (!renameSucceeded) {
					try {
						this.setFile(true);
					}
					catch(IOException e) {
						LogLog.error("setFile("+res+", true) call failed.", e);
					}
				}
			}
		}

		//   if all renames were successful, then

		if (renameSucceeded) {
			try {
				// This will also close the file. This is OK since multiple
				// close operations are safe.
				this.setFile(false);
				nextRollover = 0;
			}
			catch(IOException e) {
				LogLog.error("setFile("+res+", false) call failed.", e);
			}
		}
	}

  public
  synchronized
  void setFile(boolean append) throws IOException {
    super.setFile(append);
    if(append) {
      ((CountingQuietWriter) qw).setCount(res.length());
    }
  }


  /**
     Set the maximum number of backup files to keep around.

     <p>The <b>MaxBackupIndex</b> option determines how many backup
     files are kept before the oldest is erased. This option takes
     a positive integer value. If set to zero, then there will be no
     backup files and the log file will be truncated when it reaches
     <code>MaxFileSize</code>.
   */
  public
  void setMaxBackupIndex(int maxBackups) {
    this.maxBackupIndex = maxBackups;
  }


  protected
  void setQWForFiles(Writer writer) {
     this.qw = new CountingQuietWriter(writer, errorHandler);
  }

  /**
     This method differentiates RollingFileAppender from its super
     class.

     @since 0.9.0
  */
  protected void subAppend(LoggingEvent event) {
    super.subAppend(event);
    print.e("++"+(res  ));
    if(res != null && qw != null) {
    	long size = ((CountingQuietWriter) qw).getCount();
    	print.e("++"+size);
        if (size >= maxFileSize && size >= nextRollover) {
            rollOver();
        }
    }
   }
}