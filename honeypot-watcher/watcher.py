import base64
import sys
import time

from pygtail import Pygtail

import config
import ss


def main(file_path):
    new_lines = Pygtail(file_path)

    while True:
        logs = [line.split('|') for line in new_lines]

        if len(logs) > 0:
            datas = []
            for log in logs:
                log[0] = log[0].strip('[]').replace('+0900', '')
                log[3] = log[3].strip('"')
                log[6] = base64.b64decode(log[6]).decode()
                log.append(config.sensor_id)
                log.append(config.sensor_region)
                datas.append(log)
            ss.send_datas_to_spreadsheet(datas)

        time.sleep(1)


if __name__ == '__main__':
    file_path = sys.argv[1]
    main(file_path)
