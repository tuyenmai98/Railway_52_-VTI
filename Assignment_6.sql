/*============================== Testing_System_Assignment_6 ===========================*/
/*======================================================================================*/
-- Exercise 1: Tiếp tục với Database Testing System
-- Question 1: Tạo store để người dùng nhập vào tên phòng ban và in ra tất cả các account thuộc phòng ban đó

SELECT a.User_Name, a.Full_Name, d.Department_Name FROM Department d 
JOIN Account a ON d.Department_id = a.Department_ID
WHERE d.Department_Name = 'Thư Ký' ;

DROP PROCEDURE IF EXISTS sp_DepartAcc;

DELIMITER $$
CREATE PROCEDURE sp_DepartAcc(IN Depart_Name NVARCHAR(30))
BEGIN
	SELECT a.User_Name, a.Full_Name, d.Department_Name FROM Department d 
JOIN Account a ON d.Department_id = a.Department_ID
WHERE d.Department_Name = Depart_Name ; 
END$$
DELIMITER ;

call sp_DepartAcc('sale');

-- Question 2: Tạo store để in ra số lượng account trong mỗi group



DROP PROCEDURE IF EXISTS sp_Group_Acc;

DELIMITER $$
CREATE PROCEDURE sp_Group_Acc()
BEGIN
	SELECT g.Group_Name, count(1) AS SL_Account FROM Group_Account ga
	JOIN Gruop g ON ga.Group_ID = g.Group_ID
	GROUP BY ga.Group_ID;
END $$
DELIMITER;

call sp_Group_Acc();

-- Question 3: Tạo store để thống kê mỗi type question có bao nhiêu question được tạo trong tháng hiện tại



DROP PROCEDURE IF EXISTS sp_TyQuestion;
DELIMITER $$
CREATE PROCEDURE sp_TyQuestion()
BEGIN
	SELECT t.Type_Name , count(1) FROM Question q 
	JOIN Type_Question t ON q.Type_ID = t.Type_ID
	WHERE month(Create_Date) = month(now()) AND year(Create_Date)=year(now())
	GROUP BY q.Type_ID;

END$$
DELIMITER ;

call sp_TyQuestion();

-- Question 4: Tạo store để trả ra id của type question có nhiều câu hỏi nhất 


DROP PROCEDURE IF EXISTS sp_TyId;
DELIMITER $$
CREATE PROCEDURE sp_TyId(OUT SL_Question TINYINT)
BEGIN
	SELECT  count(1) AS SL INTO SL_Question FROM Question q
	JOIN Type_Question t ON q.Type_ID = t.Type_ID
	GROUP BY q.Type_ID
	HAVING SL = (SELECT max(a1) FROM (SELECT count(1) AS a1 FROM Question GROUP BY Type_ID ) AS tpm );
END$$
DELIMITER ;

SET @v_Sl = 0;
CALL sp_TyId(@v_Sl);
SELECT @v_Sl;

-- Question 5: Sử dụng store ở question 4 để tìm ra tên của type question


DROP PROCEDURE IF EXISTS sp_TyQuestion;
DELIMITER $$
CREATE PROCEDURE sp_TyQuestion()
BEGIN
	WITH CTE_Type AS (
    SELECT count(1) AS SL FROM Question q
	GROUP BY q.Type_ID) 
	SELECT t.Type_Name,  count(1) FROM Question q
    JOIN Type_Question t ON q.Type_ID = t.Type_ID
    GROUP BY q.Type_ID
	HAVING count(1) = (SELECT max(SL) FROM CTE_Type  );
END$$
DELIMITER ;

SET @v_Sl = 0;
CALL sp_TyQuestion(@v_Sl);
SELECT @v_SL;

-- Question 6: Viết 1 store cho phép người dùng nhập vào 1 chuỗi và trả về group có tên chứa chuỗi của người dùng nhập vào hoặc trả về 
-- user có username chứa chuỗi của người dùng nhập vào

DROP PROCEDURE IF EXISTS sp_getNameAccOrNameGroup;
DELIMITER $$
CREATE PROCEDURE sp_getNameAccOrNameGroup( IN vr_string VARCHAR(30) )
BEGIN
	SELECT g.Group_Name FROM Gruop g WHERE g.Group_Name LIKE concat('%',vr_string,'%')
    UNION
    SELECT a.User_Name FROM `Account` a WHERE a.User_Name LIKE concat('%',vr_string,'%');
END 
DELIMITER ;

CALL sp_getNameAccOrNameGroup('v');


DROP PROCEDURE IF EXISTS sp_getNameAccOrNameGroup1;
DELIMITER $$
CREATE PROCEDURE sp_getNameAccOrNameGroup1( IN vr_string VARCHAR(30), IN so INT )
BEGIN
	IF so = 1 THEN
	SELECT g.Group_Name FROM Gruop g WHERE g.Group_Name LIKE concat('%',vr_string,'%');
    ELSE
    SELECT a.User_Name FROM `Account` a WHERE a.User_Name LIKE concat('%',vr_string,'%');
    END IF;
END $$
DELIMITER ;




-- Question 7: Viết 1 store cho phép người dùng nhập vào thông tin fullName, email và trong store sẽ tự động gán:
-- username sẽ giống email nhưng bỏ phần @..mail đi positionID: sẽ có default là developer departmentID: sẽ được cho vào 1 phòng chờ
-- Sau đó in ra kết quả tạo thành công

DROP PROCEDURE IF EXISTS sp_add;
DELIMITER $$
CREATE PROCEDURE sp_add(IN fullName VARCHAR(30), IN Mail VARCHAR(30))
BEGIN
	 DECLARE s_Username VARCHAR(30) DEFAULT substring_index(Mail,'@',1);
     DECLARE s_DepartMentID INT UNSIGNED DEFAULT 1;
     DECLARE s_PositionID INT UNSIGNED DEFAULT 2;
     DECLARE s_creatDate DATETIME DEFAULT now();
     
     INSERT INTO `Account`(Email, User_Name, Full_Name, Department_ID, Position_ID, Create_Date)
     VALUES 			 (Mail , s_Username, fullName, s_DepartMentID, s_PositionID, s_creatDate   );
END $$
DELIMITER ;

CALL sp_add('maimai','maivan@gmail.com');

-- Question 8: Viết 1 store cho phép người dùng nhập vào Essay hoặc Multiple-Choice 
-- để thống kê câu hỏi essay hoặc multiple-choice nào có content dài nhất

DROP PROCEDURE IF EXISTS sp_LenghContent;
DELIMITER $$
CREATE PROCEDURE sp_LenghContent(IN choice VARCHAR(30))
BEGIN
	DECLARE v_typeId INT UNSIGNED;
    SELECT t.Type_ID INTO v_typeId FROM  Type_Question t
    WHERE t.Type_Name = choice;
    IF  choice = 'Essay' THEN    
			WITH CTE_LengContent AS(
			SELECT length(q.Content) AS leng FROM Question q
			WHERE q.Type_ID = v_typeId)
			SELECT * FROM question q
			WHERE length(q.Content) = (SELECT MAX(leng) FROM CTE_LengContent);
    ELSEIF choice = 'Multip-Choice' THEN
			WITH CTE_LengContent AS(
			SELECT length(q.Content) AS leng FROM Question q
			WHERE q.Type_ID = v_typeId)
			SELECT * FROM question q
			WHERE length(q.Content) = (SELECT MAX(leng) FROM CTE_LengContent);
    END IF;
END $$
DELIMITER ;




-- Question 9: Viết 1 store cho phép người dùng xóa exam dựa vào ID


DROP PROCEDURE IF EXISTS sp_DeleteExam;
DELIMITER $$
CREATE PROCEDURE sp_DeleteExam(IN ExamId INT)
BEGIN
	DELETE FROM Exam WHERE Exam_ID = ExamId;
END $$
DELIMITER ;



-- Question 10: Tìm ra các exam được tạo từ 3 năm trước và xóa các exam đó đi (sử dụng store ở câu 9 để xóa)
-- Sau đó in số lượng record đã remove từ các table liên quan trong khi removing

DROP PROCEDURE IF EXISTS sp_DeleteExam;
DELIMITER $$
CREATE PROCEDURE sp_DeleteExam(IN ExamId INT)
BEGIN
	DELETE FROM Exam WHERE Exam_ID = ExamId;
END $$
DELIMITER ;

-- Question 11: Viết store cho phép người dùng xóa phòng ban bằng cách người dùng nhập vào tên phòng ban và các account 
-- thuộc phòng ban đó sẽ được chuyển về phòng ban default là phòng ban chờ việc

DROP PROCEDURE IF EXISTS sp_DeleteDepartment;
DELIMITER $$
CREATE PROCEDURE sp_DeleteDepartment(IN v_DPName VARCHAR(30))
BEGIN
	DECLARE v_DPid INT UNSIGNED ;
    SELECT d.Department_id INTO v_DPid FROM Department d WHERE d.Department_Name = v_DPName;
    
	UPDATE `Account` a SET a.Department_ID = '11' WHERE a.Department_ID = v_DPid;
    
	 DELETE FROM Department d1 WHERE d1.Department_Name = v_DPName;
END $$
DELIMITER ;

call DeleteDepartment('Sale');
-- Question 12: Viết store để in ra mỗi tháng có bao nhiêu câu hỏi được tạo trong năm nay

DROP PROCEDURE IF EXISTS sp_CountQuesInMonth;
DELIMITER $$
CREATE PROCEDURE sp_CountQuesInMonth()
BEGIN
	WITH CTE_12Months AS (
	         SELECT 1 AS MONTH
             UNION SELECT 2 AS MONTH
             UNION SELECT 3 AS MONTH
             UNION SELECT 4 AS MONTH
             UNION SELECT 5 AS MONTH
             UNION SELECT 6 AS MONTH
             UNION SELECT 7 AS MONTH
             UNION SELECT 8 AS MONTH
             UNION SELECT 9 AS MONTH
             UNION SELECT 10 AS MONTH
             UNION SELECT 11 AS MONTH
             UNION SELECT 12 AS MONTH
)	
	SELECT M.MONTH, count(month(q.Create_Date)) AS SL  FROM CTE_12Months M
	LEFT JOIN (SELECT * FROM Question q1 WHERE year(q1.Create_Date) = year(now()) ) q
	ON M.MONTH = month(q.Create_Date) 
	GROUP BY M.MONTH;
END$$
DELIMITER ;

Call sp_CountQuesInMonth();

-- Question 13: Viết store để in ra mỗi tháng có bao nhiêu câu hỏi được tạo trong 6 tháng gần đây nhất
-- (Nếu tháng nào không có thì sẽ in ra là "không có câu hỏi nào trong tháng")

DROP PROCEDURE IF EXISTS sp_CountQuesBefore6Month;
DELIMITER $$
CREATE PROCEDURE sp_CountQuesBefore6Month()
BEGIN
	WITH CTE_Talbe_6MonthBefore AS (
			SELECT MONTH(DATE_SUB(NOW(), INTERVAL 5 MONTH)) AS MONTH, YEAR(DATE_SUB(NOW(), INTERVAL 5 MONTH)) AS `YEAR`
			UNION
			SELECT MONTH(DATE_SUB(NOW(), INTERVAL 4 MONTH)) AS MONTH, YEAR(DATE_SUB(NOW(), INTERVAL 4 MONTH)) AS `YEAR`
			UNION
			SELECT MONTH(DATE_SUB(NOW(), INTERVAL 3 MONTH)) AS MONTH, YEAR(DATE_SUB(NOW(), INTERVAL 3 MONTH)) AS `YEAR`
			UNION
			SELECT MONTH(DATE_SUB(NOW(), INTERVAL 2 MONTH)) AS MONTH, YEAR(DATE_SUB(NOW(), INTERVAL 2 MONTH)) AS `YEAR`
			UNION
			SELECT MONTH(DATE_SUB(NOW(), INTERVAL 1 MONTH)) AS MONTH, YEAR(DATE_SUB(NOW(), INTERVAL 1 MONTH)) AS `YEAR`
			UNION
			SELECT MONTH(NOW()) AS MONTH, YEAR(NOW()) AS `YEAR`
)
		SELECT M.MONTH,M.YEAR, CASE 
				WHEN COUNT(Question_ID) = 0 THEN 'không có câu hỏi nào trong tháng'
                ELSE COUNT(Question_ID)
				END AS SL
		FROM CTE_Talbe_6MonthBefore M
		LEFT JOIN (SELECT * FROM Question where Create_Date >= DATE_SUB(NOW(), INTERVAL 6 MONTH) AND Create_Date <= now())
        AS Sub_Question ON M.MONTH = MONTH(Create_Date)
		GROUP BY M.MONTH, M.YEAR
		ORDER BY M.MONTH ASC;
END$$
DELIMITER ;

-- Run: 
CALL sp_CountQuesBefore6Month;
