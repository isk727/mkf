#!/usr/local/bin/python3
import os
import sys
import openpyxl, csv
import paramiko

CONF_FILE = './conf.csv'
TEMP_FILE = './template/work.sql'

def main():
    data = open(CONF_FILE, "r") # 処理用パラメータ設定のCSVファイルを読み込み
    for line in data:
        line = line.replace('\n', '') # 行末の改行をとる
        dt = line.split(",")
        xlsx2csv(dt[0] + ".xlsx", dt[1] + "u.csv", dt[1] + ".csv")
        makesql(dt[1] + ".sql", dt[1], dt[2])
    data.close()
    print("[done]")

# ExcelからCSVの作成 ##############################
def xlsx2csv(exlf, csvu, csvs):
    wb = openpyxl.load_workbook(exlf)
    ws = wb.worksheets[0]
    ws.delete_cols(288,10) # 個人IDより右側を削除
    ws.delete_rows(1) # ヘッダー行を削除
    with open(csvu, 'w', newline="") as csvfile: # csv作成(utf-8)
        writer = csv.writer(csvfile)
        for row in ws.rows:
            writer.writerow( [cell.value for cell in row] )
    with open(csvu, encoding='utf-8',errors='replace') as fin: # utf-8からshift-jisに変換
        with open(csvs, 'w', encoding='Shift-JIS',errors='replace') as fout:
            fout.write(fin.read().replace('\n', '\r\n')) # 改行コード変換
    print("now [" + csvs + "] uploading...")
    putfile(csvs, "data/" + csvs) # サーバーにput
    os.remove(exlf)
    os.remove(csvu)
    os.remove(csvs)

# 実行用SQLファイル作成 ##############################
def makesql(sqlf, csvk, payd):
    with open(TEMP_FILE, encoding="utf-8") as f:
        data_lines = f.read()
    data_lines = data_lines.replace("{FILENAME}", csvk) # プレースホルダーを置き換え
    data_lines = data_lines.replace("{PAYDATE}", payd) # プレースホルダーを置き換え
    with open(sqlf, mode="w", encoding="utf-8") as f: # sqlファイルを書き込み
        f.write(data_lines)
    print("now [" + sqlf + "] uploading...")
    putfile(sqlf, "sql/" + sqlf) # サーバーにput
    os.remove(sqlf)

# ファイルをサーバーへアップロード #######################
def putfile(put_file, target_path):
    hostnm = '220.213.226.234'
    usernm = 'root'
    passwd = 'AGqk99UkPgFh.TKL'
    target_file='/usr/local/mothis/housewife/' + target_path
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=hostnm, username=usernm, password=passwd, timeout=10, look_for_keys=False)
    try:
        sftp_connection = client.open_sftp()
        sftp_connection.put(put_file, target_file)
    finally:
        client.close()

if __name__ == "__main__":
    main()
