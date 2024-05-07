# Created this python script to parse through a CSV file that is output by the Remediate-BreachedAccounts.ps1 script to provide an easier to view set of information.
# It sorta works. 
#
# Written by Jonathan Bullock
# 2024 - 05 -07 

import csv
import json

def parse_csv(file_path):
    with open(file_path, newline='', encoding='utf-8') as file:
        reader = csv.reader(file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        return [row for row in reader]

def refine_path_and_extract_details(data):
    refined_details = []
    for entry in data:
        # Extract and clean the path
        path_full = entry.get("Path", "N/A")
        # Keep only the relevant part of the path
        path_cleaned = path_full.split('",')[0] if '",' in path_full else path_full
        
        # Prepare the dictionary for this entry
        email_info = {
            "CreationTime": entry.get("CreationTime", "N/A"),
            "MailboxOwnerUPN": entry.get("MailboxOwnerUPN", "N/A"),
            "Path": path_cleaned.strip(' "}]'),  # Further cleanup of unwanted trailing characters
            "InternetMessageId": entry.get("InternetMessageId", "N/A"),
            "Subject": entry.get("Subject", "N/A")  # Maintain subject as "N/A" if not found
        }
        refined_details.append(email_info)
    
    return refined_details

def save_to_csv(data, output_file_path):
    with open(output_file_path, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=data[0].keys())
        writer.writeheader()
        for row in data:
            writer.writerow(row)

def main():
    input_file_path = 'path_to_your_input.csv'  # Adjust this to your file location
    output_file_path = 'path_to_your_output.csv'  # Desired output file location
    parsed_data = parse_csv(input_file_path)
    refined_data = refine_path_and_extract_details(parsed_data)
    save_to_csv(refined_data, output_file_path)

if __name__ == "__main__":
    main()
