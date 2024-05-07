# Created this python script to parse through a CSV file that is output by the Remediate-BreachedAccounts.ps1 script to provide an easier to view set of information.
# It sorta works. 
#
# Written by Jonathan Bullock
# 2024 - 05 -07 

import csv
import json

def parse_csv(file_path):
    # Open and read the entire file to handle it line by line
    with open(file_path, 'r', encoding='utf-8') as file:
        reader = csv.reader(file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        all_lines = [row for row in reader]
    return all_lines

def manual_parse_to_dict(line):
    # Combine the list into a single string to handle complex structures
    combined_line = "".join(line)
    # Replace problematic parts of the line here if necessary
    # Parse the combined line manually here
    return json.loads("{" + combined_line + "}")

def refine_path_and_extract_details(data):
    refined_details = []
    for entry in data:
        path_full = entry.get("Path", "N/A")
        path_cleaned = path_full.split('",')[0] if '",' in path_full else path_full
        email_info = {
            "CreationTime": entry.get("CreationTime", "N/A"),
            "MailboxOwnerUPN": entry.get("MailboxOwnerUPN", "N/A"),
            "Path": path_cleaned.strip(' "}]'),
            "InternetMessageId": entry.get("InternetMessageId", "N/A"),
            "Subject": entry.get("Subject", "N/A")
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
    parsed_lines = parse_csv(input_file_path)
    parsed_data = [manual_parse_to_dict(line) for line in parsed_lines if line]
    refined_data = refine_path_and_extract_details(parsed_data)
    save_to_csv(refined_data, output_file_path)

if __name__ == "__main__":
    main()
