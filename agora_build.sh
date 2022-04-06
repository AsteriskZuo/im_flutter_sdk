
#!/bin/bash

FILE_NAME=chat_flutter_sdk
 
rm -rf ../${FILE_NAME}
python3 update_to_agora.py -s ./ -t ../${FILE_NAME}