-- 1．	计算每个学生有成绩的课程门数、平均成绩并报表输出(要求创建过程实现)。
CREATE OR REPLACE PROCEDURE CAL_AVG AS
tab CHAR(1) := CHR(9); -- 制表符字符

BEGIN
    DBMS_OUTPUT.PUT_LINE('SNO' || tab || 'count' || tab || 'avg');

    FOR scx IN (
        SELECT SNO,COUNT(*) count, AVG(GRADE) avg
        FROM SC 
        WHERE SC.GRADE IS NOT NULL
        GROUP BY SNO
        )

    LOOP
        DBMS_OUTPUT.PUT_LINE(scx.SNO || tab || scx.count || tab || tab || scx.avg);
    END LOOP;
END;
/

BEGIN
    CAL_AVG();
END;
/

-- 2．	给定学生学号，查询其选修成绩最高的那门课的课程名（要求创建函数实现）。
CREATE OR REPLACE FUNCTION max_grade_course(para_sno INT) 
RETURN VARCHAR2
AS
tab CHAR(1) := CHR(9); -- 制表符字符
max_grade INT := -1;
cname VARCHAR2(10);
CURSOR cname_grade IS
    SELECT CNAME, GRADE
    FROM SC JOIN C ON SC.CNO = C.CNO
    WHERE SC.SNO = para_sno;
BEGIN
    FOR cname_grade_temp IN cname_grade
    LOOP
        IF cname_grade_temp.GRADE > max_grade THEN
            max_grade := cname_grade_temp.GRADE;
            cname := cname_grade_temp.CNAME;
        END IF;
    END LOOP;
    -- 
    RETURN cname;
END;
/

DECLARE 
   ret VARCHAR2(10); 
BEGIN 
   ret := max_grade_course(121); 
   DBMS_OUTPUT.PUT_LINE(ret);
END;
/

-- 3．	将选修表中成绩为NULL的选修记录删除，成绩为55-60之间的改成60分（要求使用游标实现）。
DECLARE
    CURSOR grade_null IS SELECT * FROM SC WHERE SC.GRADE IS NULL;
    CURSOR grade_dangerous IS SELECT * FROM SC WHERE SC.GRADE BETWEEN 55 AND 60;
BEGIN
    FOR p_null IN grade_null
    LOOP
        DELETE FROM SC WHERE SC.CNO = p_null.CNO AND SC.SNO = p_null.SNO;
    END LOOP;

    FOR p_dangerous IN grade_dangerous
    LOOP
       UPDATE SC
       SET GRADE = 60
       WHERE SC.CNO = p_dangerous.CNO AND SC.SNO = p_dangerous.SNO;
    END LOOP;
END;
/

-- 4．	使用GRANT语句，把对基本表S、SC、C的使用权限授给其它用户，测试with grant option。
DROP USER c##potter CASCADE;
DROP USER c##hermione CASCADE;
CREATE USER c##hermione IDENTIFIED BY 123;
CREATE USER c##potter IDENTIFIED BY 123;

GRANT SELECT,UPDATE,INSERT,DELETE ON S TO c##potter WITH GRANT OPTION;
GRANT SELECT,UPDATE,INSERT,DELETE ON SC TO c##potter WITH GRANT OPTION;
GRANT SELECT,UPDATE,INSERT,DELETE ON C TO c##potter WITH GRANT OPTION;

-- 查看用户的表权限
SELECT * FROM USER_TAB_PRIVS WHERE GRANTEE LIKE 'C##%';


-- 测试with grant option
GRANT CREATE SESSION TO c##potter;
-- conn c##potter/123;
-- GRANT SELECT,UPDATE,INSERT,DELETE ON c##zbw.S TO c##hermione;
-- conn c##zbw/15527;

-- 再次查看用户的表权限
SELECT * FROM USER_TAB_PRIVS WHERE GRANTEE LIKE 'C##%';

-- 5. 创建不同角色，并将角色赋给不同用户，同时测试从角色中收回特定权限。
DROP USER c##USER1;
DROP USER c##USER2;
DROP USER c##USER3;

DROP ROLE c##role1;
DROP ROLE c##role2;
DROP ROLE c##role3;

CREATE ROLE c##role1;
CREATE ROLE c##role2;
CREATE ROLE c##role3;

CREATE USER c##USER1 IDENTIFIED BY user1;
CREATE USER c##USER2 IDENTIFIED BY user2;
CREATE USER c##USER3 IDENTIFIED BY user3;

select * from dba_users WHERE USERNAME LIKE 'C##%';-- 查看测试用户是否创建成功
select * from dba_roles WHERE ROLE LIKE 'C##%';-- 查看测试角色是否创建成功

-- 将角色赋给不同用户
GRANT c##role1 TO c##USER1;
GRANT c##role2 TO c##USER2;
GRANT c##role3 TO c##USER3;

-- 给角色授权
GRANT SELECT ON S TO c##role1;
GRANT UPDATE ON S TO c##role2;
GRANT INSERT ON S TO c##role3;
GRANT SELECT ON S TO PUBLIC;
COMMIT;

-- 查看角色的表权限
SELECT * FROM ROLE_TAB_PRIVS WHERE ROLE LIKE 'C##%';

-- 收回role1 SELECT权限
REVOKE SELECT ON S FROM c##role1;

-- 再次查看角色的表权限
SELECT * FROM ROLE_TAB_PRIVS WHERE ROLE LIKE 'C##%';




-- 测试语句--------------------------------------------

-- SELECT * FROM SC JOIN C ON SC.CNO = C.CNO;
-- SELECT * FROM S;
-- SELECT * FROM SC WHERE SC.GRADE IS NULL;
-- SELECT * FROM SC WHERE SC.GRADE BETWEEN 55 AND 60;
-- UPDATE SC SET GRADE = 60;
-- SELECT * FROM USER_SYS_PRIVS; -- 系统级权限
-- SELECT * FROM USER_TAB_PRIVS; -- 表级权限
-- SELECT * FROM USER_ROLE_PRIVS; -- 角色级权限

-- SELECT privilege
-- FROM user_tab_privs;
-- WHERE table_name = 'S' AND privilege = 'GRANT';