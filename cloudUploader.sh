#!/bin/sh

if [ $# -ne 2 ]; then
  echo "Please pass two parameters."
  exit 1
fi

FILEPATH="$1"
DESTINATION_PATH="$2"

# get the filename from the positional argument
file_name=$(basename -- "$FILEPATH" ) 

cloudUploader() {
    if [ -f "$FILEPATH" ]; then
        if aws s3 ls "$DESTINATION_PATH"/"$file_name"; then  # Check if file exists on cloud
           while true; do
                echo "File already exists on cloud. Choose an action: (o)verwrite, (s)kip, (r)ename:"
                read action

                case "$action" in
                    o)
                        # Overwrite: Proceed with upload
                        if aws s3 cp "$FILEPATH" "$DESTINATION_PATH"/"$file_name"; then
                            echo "File overwritten successfully."
                        else
                            echo "Upload failed."
                        fi
                        break
                        ;;
                    s)
                        echo "File skipped."
                        break
                        ;;
                    r)
                        echo "Enter a new name for the file:"
                        # receive the variable from the terminal
                        read new_name
                        # create a new destination file name
                        new_destination="$DESTINATION_PATH/$new_name"  # Append new name to destination
                        if aws s3 cp "$FILEPATH" "$new_destination"; then
                            echo "File renamed and uploaded successfully."
                        else
                            echo "Renaming and upload failed."
                        fi
                        break
                        ;;
                    *)
                        echo "Invalid action."
                        ;;
                esac
            done
        else
            # File doesn't exist on cloud, proceed with upload
            if aws s3 cp "$FILEPATH" "$DESTINATION_PATH"; then
                echo "Upload successful."
            else
                echo "Upload failed."
            fi
        fi
    else
        echo "File does not exist."
    fi
       
}

cloudUploader