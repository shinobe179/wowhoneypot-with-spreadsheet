import base64
import sys
import time
import pandas as pd
from watchdog.observers import Observer
from watchdog.events import PatternMatchingEventHandler

import config
import ss


class TextFileEventHandler(PatternMatchingEventHandler):

    def __init__(self, path, file_name, patterns=['*'], ignore_patterns=None, ignore_directories=True, case_sensitive=False):
        self.path = path 
        self.file_name = file_name
        self.fullpath = path + file_name
        self.df = self._save_df()
        self.df_row_cnt = -1 
        super().__init__(patterns, ignore_patterns, ignore_directories, case_sensitive)
   
    def on_modified(self, event):
        """監視対象ファイルに変更があった時に実行される処理"""

        if event.src_path[-len(self.file_name):] != self.file_name:
            return
        
        before_df_row_cnt = self.df_row_cnt
        self.df = self._save_df()
        self.df_row_cnt = self._check_df_length()

        # ここから任意の処理
        rows = []
        for log in self.df[before_df_row_cnt:].to_numpy().tolist():
            log[0] = log[0].strip('[]').replace('+0900', '')
            log[6] = base64.b64decode(log[6]).decode()
            log.append(config.sensor_id)
            log.append(config.sensor_region)
            rows.append(log)
        ss.append_rows(rows)

    def _check_df_length(self):
        """self.dfの行数を返す"""
        row_cnt = len(self.df)
        return row_cnt

    def _save_df(self):
        """self.fullpathで指定したファイルをPandas.Dataframeの形式で取得する"""
        df = pd.read_csv(self.fullpath, header=None, delimiter='|')
        return df
    
    def _print_df(self, start):
        """指定したファイルのstartから最終行までを表示する"""
        print(self.df[start:].to_string(index=False, header=None))


def main():

    DIRECTORY = sys.argv[1] 
    FILE = sys.argv[2]

    observer = Observer()
    observer.schedule(TextFileEventHandler(DIRECTORY, FILE), DIRECTORY, recursive=False) 
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.unschedule_all()
        observer.stop()


if __name__ == '__main__':
    main()
