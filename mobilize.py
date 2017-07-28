#! /usr/bin/python
# Search for all books without a .mobi version, convert it, then add it to calibredb
import os, json;

search_command = '/opt/calibre/calibredb list --for-machine -f formats --with-library ' + os.environ['CALIBRE_LIBRARY_DIRECTORY']
convert_path = os.environ['CALIBRE_LIBRARY_DIRECTORY'] + '/temp.mobi'

for book in json.load(os.popen(search_command)):
  mobi_found = 0
  for book_format in book['formats']:
    filename, file_extension = os.path.splitext(book_format)
    if file_extension == '.mobi':
      mobi_found = 1
  if mobi_found == 0:
    convert_command = '/opt/calibre/ebook-convert "' + book_format + '" ' + convert_path
    add_command = '/opt/calibre/calibredb add_format ' + str(book['id']) + ' ' + convert_path + ' --with-library ' + os.environ['CALIBRE_LIBRARY_DIRECTORY']
    os.system(convert_command)
    os.system(add_command)
