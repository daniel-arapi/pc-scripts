"""
Class recordings are downloaded to Class Recordings directory which contains a subdirectory for each class of that year.
Each class subdirectory contains mp4 video, txt transcription, vm4a audio, and vtt closed captions.
All of these files need to be renamed to show date and class in a more readable format.
Example below:

- 'Class Recording'
  - 'Year 1 - Period 1 - QUR-111 - Applied Grammar and Quran Translation'
    - GMT20241010-173029_Recording.cc.vtt --> "2024-10-10 - Year 1 - Period 1 - QUR-111 - Applied Grammar and Quran Translation.vtt"
    - GMT20241010-173029_Recording.m4a --> "2024-10-10 - Year 1 - Period 1 - QUR-111 - Applied Grammar and Quran Translation.vm4a"
    - GMT20241010-173029_Recording_1920x1080.mp4 --> "2024-10-10 - Year 1 - Period 1 - QUR-111 - Applied Grammar and Quran Translation.mp4"
    - GMT20241010-173029_RecordingnewChat.txt --> "2024-10-10 - Year 1 - Period 1 - QUR-111 - Applied Grammar and Quran Translation.txt"
"""

import os
import re
from datetime import datetime

# Set the path to the main directory
main_directory = r"C:\Users\arapi\Dropbox\qalam-seminary\Class Recordings"

# Regex to extract the GMT timestamp
gmt_pattern = re.compile(r"GMT(\d{8})-\d{6}")


# Function to convert GMT timestamp to YYYY-MM-DD format
def convert_gmt_to_date(gmt_string):
    date_obj = datetime.strptime(gmt_string, "%Y%m%d")
    return date_obj.strftime("%Y-%m-%d")


# Function to get a list of files in a directory and rename them
def rename_files_in_directory(directory):
    # Track files with the same name and extension
    file_count = {}

    for root, _, files in os.walk(directory):
        # Get the directory name part to append to the file name
        directory_name = os.path.basename(root)

        for file_name in files:
            # Match the GMT timestamp in the file name
            gmt_match = gmt_pattern.search(file_name)
            if gmt_match:
                # Extract and convert the GMT timestamp
                gmt_timestamp = gmt_match.group(1)
                date_string = convert_gmt_to_date(gmt_timestamp)

                # Extract file extension
                file_extension = os.path.splitext(file_name)[1]

                # Create the new base file name (without "part")
                new_base_name = f"{date_string} - {directory_name}{file_extension}"

                # Create a key based on the base name and extension
                file_key = f"{new_base_name}"

                # Check if we've already encountered this base name with the same extension
                if file_key not in file_count:
                    file_count[file_key] = 0

                file_count[file_key] += 1
                part_suffix = f" - part {file_count[file_key]}" if file_count[file_key] > 1 else ""

                # Create the new file name with "part" only if necessary
                new_file_name = f"{date_string} - {directory_name}{part_suffix}{file_extension}"

                # Get the full original and new file paths
                original_file_path = os.path.join(root, file_name)
                new_file_path = os.path.join(root, new_file_name)

                # Rename the file
                os.rename(original_file_path, new_file_path)
                print(f"Renamed: {original_file_path} -> {new_file_path}")


# Call the function to rename files in the main directory
rename_files_in_directory(main_directory)
