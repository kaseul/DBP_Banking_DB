DROP TABLE remitTbl;
DROP TABLE remitFavTbl;
DROP TABLE accountTbl;
DROP TABLE bankTbl;
DROP TABLE userTbl;

DROP SEQUENCE NOSEQ;

-- 회원 테이블 : userTbl
CREATE TABLE userTbl (
    id varchar2(8) primary key,
    password varchar2(12) not null,
    uname nvarchar2(4) not null,
    birth date not null,
    tel varchar2(11) not null
);

-- 은행 테이블 : bankTbl
CREATE TABLE bankTbl (
    bcode char(2) primary key,
    bname nvarchar2(9) not null,
    commission number(4) default 0
);

-- 계좌 테이블 : accountTbl
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

-- 송금 로그 테이블 : remitTbl
CREATE TABLE remitTbl (
    no number(11) primary key,
    outaid varchar2(16),
    inaid varchar2(16),
    price number(7) not null,
    commission number(4, 0) default 0,
    remit_date date default sysdate
);

CREATE SEQUENCE NOSEQ INCREMENT BY 1 START WITH 1;

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

-- 자주 송금한 계좌 테이블 : remitFavTbl
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

-- INDEX
CREATE INDEX idx_remitTbl_outaid ON remitTbl(outaid);
CREATE INDEX idx_remitTbl_inaid ON remitTbl(inaid);
CREATE INDEX idx_remitTbl_remit_date ON remitTbl(remit_date);
CREATE INDEX idx_remitFavTbl_outaid ON remitFavTbl(outaid);
CREATE INDEX idx_remitFavTbl_inaid ON remitFavTbl(inaid);

-- TRIGGER
-- 송금 시 계좌 돈 관리
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
-- 월을 1~9월달은 한글자로 나타내는 함수
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

-- VIEW
-- 송금 내용을 조인하는 뷰
CREATE OR REPLACE VIEW remitJoinView AS
SELECT u.uname outname, b.bname outbname, outaid outaid, u2.uname inname, b2.bname inbname, inaid inaid, price, remit_date 
FROM userTbl u, bankTbl b, accountTbl a, remitTbl r, accountTbl a2, bankTbl b2, userTbl u2
WHERE r.outaid = a.aid AND a.bcode = b.bcode AND a.id = u.id AND r.inaid = a2.aid AND a2.bcode = b2.bcode AND a2.id = u2.id;

-- 더미 데이터 INSERT
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('01', N'KB국민은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('02', N'KDB산업은행', 0);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('03', N'NH농협은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('04', N'신한은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('05', N'우리은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('06', N'SC제일은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('07', N'KEB하나은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('08', N'IBK기업은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('09', N'한국씨티은행', 0);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('10', N'SH수협은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('11', N'DGB대구은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('12', N'BNK부산은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('13', N'광주은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('14', N'제주은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('15', N'전북은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('16', N'BNK경남은행', 500);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('17', N'케이뱅크은행', 0);
INSERT INTO BANKTBL (BCODE, BNAME, COMMISSION) VALUES ('18', N'한국카카오은행', 0);
COMMIT;
