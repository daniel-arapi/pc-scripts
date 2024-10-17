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

                # Create the new base file name
                new_base_name = f"{date_string} - {directory_name}{file_extension}"

                # Initialize the new file name
                new_file_name = new_base_name
                new_file_path = os.path.join(root, new_file_name)

                # Check if the new file name already exists, add 'part' suffix if necessary
                part_number = 1
                while os.path.exists(new_file_path):
                    part_number += 1
                    new_file_name = f"{date_string} - {directory_name} - part {part_number}{file_extension}"
                    new_file_path = os.path.join(root, new_file_name)

                # Get the full original file path
                original_file_path = os.path.join(root, file_name)

                # Rename the file
                os.rename(original_file_path, new_file_path)
                print(f"Renamed: {original_file_path} -> {new_file_path}")

# Call the function to rename files in the main directory
rename_files_in_directory(main_directory)
