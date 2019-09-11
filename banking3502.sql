DROP TABLE remitTbl;
DROP TABLE remitFavTbl;
DROP TABLE accountTbl;
DROP TABLE bankTbl;
DROP TABLE userTbl;

DROP SEQUENCE NOSEQ;

-- ȸ�� ���̺� : userTbl
CREATE TABLE userTbl (
    id varchar2(8) primary key,
    password varchar2(12) not null,
    uname nvarchar2(4) not null,
    birth date not null,
    tel varchar2(11)
);

-- ���� ���̺� : bankTbl
CREATE TABLE bankTbl (
    bcode char(2) primary key,
    bname nvarchar2(9) not null,
    commission number(4) default 0
);

-- ���� ���̺� : accountTbl
CREATE TABLE accountTbl (
    aid varchar2(16) primary key,
    id varchar2(8),
    bcode char(2),
    balance number(10) default 0
);

ALTER TABLE ACCOUNTTBL
ADD CONSTRAINT ACCOUNTTBL_FK1 FOREIGN KEY (ID)
REFERENCES USERTBL (ID)
ENABLE;

ALTER TABLE ACCOUNTTBL
ADD CONSTRAINT ACCOUNTTBL_FK2 FOREIGN KEY (BCODE)
REFERENCES BANKTBL (BCODE)
ENABLE;

CREATE SEQUENCE NOSEQ INCREMENT BY 1 START WITH 1;

-- �۱� �α� ���̺� : remitTbl
CREATE TABLE remitTbl (
    no number(11) primary key,
    outaid varchar2(16),
    inaid varchar2(16),
    price number(7) not null,
    commission number(4, 0) default 0,
    remit_date date default sysdate
);

CREATE TRIGGER REMITTBL_TRG 
BEFORE INSERT ON REMITTBL 
FOR EACH ROW 
BEGIN
  <<COLUMN_SEQUENCES>>
  BEGIN
    IF INSERTING AND :NEW.NO IS NULL THEN
      SELECT NOSEQ.NEXTVAL INTO :NEW.NO FROM SYS.DUAL;
    END IF;
  END COLUMN_SEQUENCES;
END;
/

ALTER TABLE REMITTBL
ADD CONSTRAINT REMITTBL_FK1 FOREIGN KEY (OUTAID)
REFERENCES ACCOUNTTBL (AID)
ENABLE;

ALTER TABLE REMITTBL
ADD CONSTRAINT REMITTBL_FK2 FOREIGN KEY (INAID)
REFERENCES ACCOUNTTBL (AID)
ENABLE;

-- ���� �۱��� ���� ���̺� : remitFavTbl
CREATE TABLE remitFavTbl (
    outaid varchar2(16) not null,
    inaid varchar2(16) not null,
    count number(11) default 1
);

ALTER TABLE REMITFAVTBL
ADD CONSTRAINT REMITFAVTBL_FK1 FOREIGN KEY (OUTAID)
REFERENCES ACCOUNTTBL (AID)
ENABLE;

ALTER TABLE REMITFAVTBL
ADD CONSTRAINT REMITFAVTBL_FK2 FOREIGN KEY (INAID)
REFERENCES ACCOUNTTBL (AID)
ENABLE;

-- TRIGGER
-- �۱� �� ���� �� ����
CREATE OR REPLACE TRIGGER remit
AFTER INSERT ON remitTbl
FOR EACH ROW
BEGIN
  UPDATE accountTbl SET balance=balance-:NEW.price-:NEW.commission WHERE aid=:NEW.outaid;
  UPDATE accountTbl SET balance=balance+:NEW.price WHERE aid=:NEW.inaid;
  MERGE INTO remitFavTbl F
  USING dual
  ON (F.outaid = :NEW.outaid AND F.inaid = :NEW.inaid)
  WHEN MATCHED THEN
    UPDATE SET F.count=F.count+1
  WHEN NOT MATCHED THEN
    INSERT(F.outaid, F.inaid)
    VALUES(:NEW.outaid, :NEW.inaid);
END;
/

-- STORED FUNCTION
-- ���� 1~9������ �ѱ��ڷ� ��Ÿ���� �Լ�
CREATE OR REPLACE FUNCTION fnMonth(remit_date IN Date)
RETURN VARCHAR
IS
  month VARCHAR2(7);
BEGIN
  month := TO_CHAR(remit_date, 'RRRR/MM');
  IF(SUBSTR(month, 6, 1) = '0') THEN month:=CONCAT(SUBSTR(month, 1, 5), SUBSTR(month, 7)); END IF;
  return month;
END;
/

-- ���� ������ INSERT
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('01', N'KB��������', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('02', N'KDB�������', 0);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('03', N'NH��������', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('04', N'��������', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('05', N'�츮����', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('06', N'���Ĵٵ���Ÿ������', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('07', N'KEB�ϳ�����', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('08', N'IBK�������', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('09', N'�ѱ���Ƽ����', 0);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('10', N'SH��������', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('11', N'DGB�뱸����', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('12', N'BNK�λ�����', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('13', N'��������', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('14', N'��������', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('15', N'��������', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('16', N'BNK�泲����', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('17', N'���̹�ũ����', 0);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('18', N'�ѱ�īī������', 0);
COMMIT;

--SELECT TEST
SELECT * FROM accountTbl WHERE id = 'ddd';
