import gspread
from oauth2client.service_account import ServiceAccountCredentials

import config

# use creds to create a client to interact with the Google Drive API
scope =['https://spreadsheets.google.com/feeds', 'https://www.googleapis.com/auth/drive']
creds = ServiceAccountCredentials.from_json_keyfile_name('client_secret.json', scope)
client = gspread.authorize(creds)

# Find a workbook by name and open the first sheet
# Make sure you use the right name here.
sheet = client.open(config.book_name).worksheet(config.sheet_name)


def send_datas_to_spreadsheet(datas):
    for data in datas:
        sheet.append_row(data)

