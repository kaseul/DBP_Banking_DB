--������ ���� ��ȸ
SELECT * FROM tab;
SELECT * FROM dict;
SELECT * FROM USER_INDEXES;

--Stored Function(����������Լ�)
--1~n������ ��
CREATE OR REPLACE FUNCTION fnSum(n IN NUMBER)
RETURN NUMBER
IS
  s NUMBER:=0;
BEGIN
  --for(int i = 1; i <= n; i++) s=s+i;
  FOR i IN 1..n LOOP s:=s+i; END LOOP;
  RETURN s;
END;
/
SELECT fnSum(100) FROM dual;

--�ֹι�ȣ�� �̿��ؼ� ���� ����
CREATE OR REPLACE FUNCTION fnGender(sn IN VARCHAR)
RETURN NVARCHAR2
IS
  gen NVARCHAR2(2):='����';
BEGIN
  IF LENGTH(sn) != 13 THEN RAISE_APPLICATION_ERROR(-20000, '�ֹι�ȣ�� 13�ڸ��Դϴ�.'); END IF;
  IF mod(substr(sn, 7, 1), 2) = 1 THEN gen:='����'; END IF;
  RETURN gen;
END;
/
SELECT fnGender('0105174900000') FROM dual;

--�ֹι�ȣ�� �̿��ؼ� ������� ����
CREATE OR REPLACE FUNCTION fnBirth(sn IN VARCHAR)
RETURN DATE
IS
BEGIN
  IF LENGTH(sn) != 13 THEN RAISE_APPLICATION_ERROR(-20000, '�ֹι�ȣ�� 13�ڸ��Դϴ�.'); END IF;
  RETURN TO_DATE(substr(sn, 1, 6), 'RRMMDD');
END;
/
SELECT fnBirth('0105174900000') FROM dual;

--�ֹι�ȣ�� �̿��ؼ� ���� ����
CREATE OR REPLACE FUNCTION fnAge(sn IN VARCHAR)
RETURN NUMBER
IS
  age NUMBER;
BEGIN
  IF LENGTH(sn) != 13 THEN RAISE_APPLICATION_ERROR(-20000, '�ֹι�ȣ�� 13�ڸ��Դϴ�.'); END IF;
  age:=TO_NUMBER(TO_CHAR(sysdate, 'RRRR') - TO_CHAR(fnBirth(sn), 'RRRR'));
  RETURN age;
END;
/
SELECT fnAge('0105174900000') FROM dual;

--TRIGGER
CREATE TABLE tr_main(id VARCHAR(1), value VARCHAR(10));
CREATE TABLE tr_sub(id VARCHAR(1), value VARCHAR(10));

CREATE OR REPLACE TRIGGER tr_main_sub
AFTER INSERT ON tr_main 
FOR EACH ROW
BEGIN
  INSERT INTO tr_sub(id, value) VALUES (:NEW.id, :NEW.value);
END;
/

SELECT * FROM tr_main;
SELECT * FROM tr_sub;

INSERT INTO tr_main VALUES(1, 'TEST');
INSERT INTO tr_main VALUES(2, 'AAAA');

--������û ����
CREATE TABLE stdTbl(name VARCHAR(20) NOT NULL, subject VARCHAR(10));
CREATE TABLE subTbl(subject VARCHAR(10), cnt NUMBER(3) default 0);

SELECT * FROM stdTbl;
SELECT * FROM subTbl;

INSERT INTO subTbl(subject) VALUES('��ǻ��');
INSERT INTO subTbl(subject) VALUES('������');
INSERT INTO subTbl(subject) VALUES('�̼�');

CREATE OR REPLACE TRIGGER apply_sub
AFTER INSERT ON stdTbl
FOR EACH ROW
BEGIN
  UPDATE subTbl SET cnt=cnt+1 WHERE subject=:NEW.subject;
END;
/

INSERT INTO stdTbl VALUES('A', '��ǻ��');
INSERT INTO stdTbl VALUES('B', '�̼�');
INSERT INTO stdTbl VALUES('C', '��ǻ��');
INSERT INTO stdTbl VALUES('D', '������');