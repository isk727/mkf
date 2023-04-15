-- 2008.11.20 データフォーマット変更に伴う改訂版

-- 2014.10.28
SET character_set_database=sjis;

-- 準備:一時テーブルを空にする
delete from t_housewife2;

-- csvファイルからの読み込み
-- load data infile '/usr/local/mothis/housewife/data/201712_0329.csv' 
-- 環境が変わったためか、 "load data local infile" にしないとエラーになる (2018.03.22)
load data local infile '/usr/local/mothis/housewife/data/{FILENAME}.csv'
into table t_housewife2 fields terminated by ',' lines terminated by '\r\n'
(field001,field002,field003,field004,field005,field006,field007,field008,field009,field010,
field011,field012,field013,field014,field015,field016,field017,field018,field019,field020,
field021,field022,field023,field024,field025,field026,field027,field028,field029,field030,
field031,field032,field033,field034,field035,field036,field037,field038,field039,field040,
field041,field042,field043,field044,field045,field046,field047,field048,field049,field050,
field051,field052,field053,field054,field055,field056,field057,field058,field059,field060,
field061,field062,field063,field064,field065,field066,field067,field068,field069,field070,
field071,field072,field073,field074,field075,field076,field077,field078,field079,field080,
field081,field082,field083,field084,field085,field086,field087,field088,field089,field090,
field091,field092,field093,field094,field095,field096,field097,field098,field099,field100,
field101,field102,field103,field104,field105,field106,field107,field108,field109,field110,
field111,field112,field113,field114,field115,field116,field117,field118,field119,field120,
field121,field122,field123,field124,field125,field126,field127,field128,field129,field130,
field131,field132,field133,field134,field135,field136,field137,field138,field139,field140,
field141,field142,field143,field144,field145,field146,field147,field148,field149,field150,
field151,field152,field153,field154,field155,field156,field157,field158,field159,field160,
field161,field162,field163,field164,field165,field166,field167,field168,field169,field170,
field171,field172,field173,field174,field175,field176,field177,field178,field179,field180,
field181,field182,field183,field184,field185,field186,field187,field188,field189,field190,
field191,field192,field193,field194,field195,field196,field197,field198,field199,field200,
field201,field202,field203,field204,field205,field206,field207,field208,field209,field210,
field211,field212,field213,field214,field215,field216,field217,field218,field219,field220,
field221,field222,field223,field224,field225,field226,field227,field228,field229,field230,
field231,field232,field233,field234,field235,field236,field237,field238,field239,field240,
field241,field242,field243,field244,field245,field246,field247,field248,field249,field250,
field251,field252,field253,field254);


-- keyの設定(ファイル名) 
update t_housewife2 set fdinfo='{FILENAME}';
-- 全角数字を半角に
-- 2008/11/21 field017で変更なし
update t_housewife2 set field017=replace(field017,'０','0');
update t_housewife2 set field017=replace(field017,'１','1');
update t_housewife2 set field017=replace(field017,'２','2');
update t_housewife2 set field017=replace(field017,'３','3');
update t_housewife2 set field017=replace(field017,'４','4');
update t_housewife2 set field017=replace(field017,'５','5');
update t_housewife2 set field017=replace(field017,'６','6');
update t_housewife2 set field017=replace(field017,'７','7');
update t_housewife2 set field017=replace(field017,'８','8');
update t_housewife2 set field017=replace(field017,'９','9');
update t_housewife2 set field017=replace(field017,'　','');

-- 前ゼロをとる処理
-- 2008/11/21 field017,field018で変更なし
update t_housewife2 set field017=field017+0;
update t_housewife2 set field018=field018+0;


-- 173?  C6,C3 ? (like C%)
-- kns_age2,kns_age3,kns_tokutei_flagをnullで追加
insert into t_kenshin
select
null,
'3' as kns_uketuke_num,
if(isnull(emp_num),field014,emp_num) as emp_num,
if(isnull(emp_name),'[不明]',emp_name) as emp_name,
'妻' as kns_zokugara,
if(isnull(kzk_name),field007,kzk_name) as kzk_name,
'' as kns_read,
if(isnull(kzk_birthday),field009,kzk_birthday) as kzk_birthday,
'' as KNS_ADDRESS,
'' as KNS_RENRAKU_TEL,
field020 as KNS_DATE,
trim(field002) as KNS_HOSPITAL,
'主婦健診' as KNS_TYPE,
1 as KNS_SEX,
field014 as KNS_MNG_NUM,
now() as KNS_INP_DATE,
if(isnull(emp_mail),'',emp_mail) as emp_mail,
'' as KNS_SECTION,
'' as KNS_EXT,
field011 as KNS_AGE,
null,
null,
'' as KNS_SESSION_ID,
0 as KNS_FAMILY_FLAG,
3 as KNS_IMPORT_FLAG,
now() as KNS_IMPORT_DATE,
0 as KNS_CHARGE,
field020 as KNS_KNS_DATE,
0 as KNS_STAY,
'{PAYDATE}' as KNS_PAY_DATE,
if(field182 like 'C%' or field182 like 'D%',1,0) as KNS_SAIKENSA,
0 as KNS_ORG_FLAG,
'' as KNS_CHG_DATE,
fdinfo as kns_imp_key,
null,5,0
from t_housewife2
left join t_emp on (field017=emp_type_code and field018=emp_ins_num)
left join t_kazoku on (emp_num=kzk_emp_num and kzk_zokugara_code=20);


-- [健診種別テーブルへimport]
insert into t_kenshin_type 
select null,kns_id,mskt_code,kns_type,kns_pay_date,kns_charge,kns_imp_key,null,null 
from t_kenshin 
left join t_ms_kns_type on kns_type=mskt_name
left join t_kenshin_type on kns_id=kt_kns_id 
where kns_type like '%主婦健診%' and 
kt_id is null and 
kns_imp_key='{FILENAME}'
order by kns_id;

-- [housewifeテーブルのフラグを更新] -----------------------------
update t_housewife set import_flag=1 where fdinfo='{FILENAME}';

-- [受付番号の準備] -----------------------------
update t_kenshin set kns_uketuke_num='305' where kns_imp_key='{FILENAME}';
