-- Criando a tabela Employee_Attrition e copiando os dados do arquivo csv para a tabela

CREATE TABLE Employee_Attrition (
	Age integer, Attrition varchar(50), BusinessTravel varchar(50),
	DailyRate integer, Department varchar(50), DistanceFromHome integer,
	Education integer, EducationField varchar(50), EmployeeCount integer,
	EmployeeNumber integer, EnvironmentSatisfaction integer, Gender varchar(50),
	HourlyRate integer, JobInvolvement integer, JobLevel integer,
	JobRole varchar(50), JobSatisfaction integer, MaritalStatus varchar(50),
	MonthlyIncome integer, MonthlyRate integer, NumCompaniesWorked integer,
	Over18 varchar(50), OverTime varchar(50), PercentSalaryHike integer,
	PerformanceRating integer, RelationshipSatisfaction integer,StandardHours integer,
	StockOptionLevel integer, TotalWorkingYears integer, TrainingTimesLastYear integer,
	WorkLifeBalance integer, YearsAtCompany integer, YearsInCurrentRole integer,
	YearsSinceLastPromotion integer, YearsWithCurrManager integer);

COPY Employee_Attrition
	(Age,Attrition, BusinessTravel, DailyRate, Department,
	DistanceFromHome, Education, EducationField, EmployeeCount, EmployeeNumber,
	EnvironmentSatisfaction,Gender, HourlyRate, JobInvolvement, JobLevel, JobRole,
	JobSatisfaction, MaritalStatus, MonthlyIncome, MonthlyRate, NumCompaniesWorked,
	Over18, OverTime, PercentSalaryHike, PerformanceRating, RelationshipSatisfaction,
	StandardHours, StockOptionLevel, TotalWorkingYears, TrainingTimesLastYear, WorkLifeBalance,
	YearsAtCompany, YearsInCurrentRole, YearsSinceLastPromotion, YearsWithCurrManager) 
	FROM 'c:\HR_Employee.csv' DELIMITER ',' CSV HEADER;


-- Total de funcionários por departamento

SELECT 
	department AS "Departamento", 
	COUNT(department) AS "Total de Funcionarios"
FROM Employee_Attrition
GROUP BY department
ORDER BY "Total de Funcionarios" DESC


-- Análise da taxa de atrito

SELECT 
	department AS "Departamento",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários com Atrito",
	SUM(CASE WHEN Attrition = 'No' THEN 1 ELSE 0 END) AS "Funcionários sem Atrito",
	TO_CHAR(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00 / COUNT(*),'FM99G999D99') 
	|| '%' AS "Taxa de Atrito",
	TO_CHAR(SUM(CASE WHEN Attrition = 'No' THEN 1 ELSE 0 END) * 100.00 / COUNT(*),'FM99G999D99') 
	|| '%' AS "Taxa de Permanência"
	
FROM Employee_Attrition
GROUP BY Department
ORDER BY "Taxa de Atrito" DESC


-- Análise da Média Salarial, Maior Salário e Menor Salário por departamento e por saída ou permanência

SELECT 
	department AS "Departamento",
	attrition AS "Saída",
	'R$ ' || TO_CHAR(ROUND(AVG(Monthlyincome),2),'FM999G999D99') AS "Média Salarial",
	'R$ ' || TO_CHAR(ROUND(MAX(Monthlyincome),2),'FM999999G999') AS "Maior Salário",
	'R$ ' || TO_CHAR(ROUND(MIN(Monthlyincome),2),'FM999999G999') AS "Menor Salário"

FROM 
	Employee_Attrition
GROUP BY attrition, department
ORDER BY "Média Salarial" DESC


-- Analisando as Médias de Satisfações por Departamento

SELECT 
	department AS "Departamento",
	ROUND(AVG(environmentsatisfaction),2) AS "Média de Satisfação do Ambiente", 
	ROUND(AVG(jobsatisfaction),2) AS "Média de Satisfação do Trabalho", 
	ROUND(AVG(relationshipsatisfaction),2) AS "Média de Satisfação do Relacionamento",
	ROUND((ROUND(AVG(EnvironmentSatisfaction),2) + ROUND(AVG(jobsatisfaction),2) 
		   + ROUND(AVG(relationshipsatisfaction),2))/3,2) AS "Média das Satisfações"
FROM
	Employee_Attrition
GROUP BY department
ORDER BY "Média das Satisfações"
	

-- Analisando as Médias de Satisfações por Departamento e por Attrition

SELECT 
	department AS "Departamento",
	attrition AS "Saída",
	ROUND((ROUND(AVG(EnvironmentSatisfaction),2) + ROUND(AVG(jobsatisfaction),2) 
		   + ROUND(AVG(relationshipsatisfaction),2))/3,2) AS "Média das Satisfações"
FROM
	Employee_Attrition
GROUP BY department, attrition
ORDER BY "Média das Satisfações", department
	

-- Análise da Diferença Salarial por Permanência em porcentagem

SELECT 
	department AS "Departamento",
	TO_CHAR(ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN MonthlyIncome END),2),'R$ ' || 'FM999G999D99') 
	AS "Média Salarial Saída",
	TO_CHAR(ROUND(AVG(CASE WHEN Attrition = 'No' THEN MonthlyIncome END),2),'R$ ' || 'FM999G999D99')
	AS "Média Salarial Permanência", 
	TO_CHAR(ABS(ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN MonthlyIncome END),2) -
	ROUND(AVG(CASE WHEN Attrition = 'No' THEN MonthlyIncome END),2)) / 
			(ROUND(AVG(CASE WHEN Attrition = 'No' THEN MonthlyIncome END),2)) * 
			100,'FM99999D99' || '%') AS "Diferença Salarial por Permanência (%)"
	
FROM
	Employee_Attrition
GROUP BY department


-- Análise de porcentagem de Hora Extra independente de saída ou ficada

SELECT 
	department AS "Departamento",
	overtime AS "Hora Extra",
	COUNT(*) AS "Total de Funcionários",
	TO_CHAR(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (PARTITION BY department),2),'FM99G99D99' || '%')
	AS "Frequência Relativa de Hora Extra"
FROM
	Employee_Attrition
GROUP BY department, overtime
ORDER BY department, overtime 


-- Análise de Hora Extra dos funcionários que deixaram a empresa por Departamento

SELECT 
	department AS "Departamento",
	overtime AS "Hora Extra",
	COUNT(*) AS "Total de Funcionários",
	TO_CHAR(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (PARTITION BY department),2),'FM99G99D99' || '%')
	AS "Porcentagem Funcionários Saíram"
FROM
	Employee_Attrition
WHERE
	attrition = 'Yes'
GROUP BY department, overtime
ORDER BY department 


-- Análise de Hora Extra dos funcionários que permaneceram na empresa por Departamento

SELECT 
	department AS "Departamento",
	overtime AS "Hora Extra",
	COUNT(*) AS "Total de Funcionários",
	TO_CHAR(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (PARTITION BY department),2),'FM99G99D99' || '%')
	AS "Porcentagem Funcionários Permaneceram"
FROM
	Employee_Attrition
WHERE
	attrition = 'No'
GROUP BY department, overtime
ORDER BY department 


-- Média de Aumento do Salário por Permanência e por Departamento

SELECT
	department AS "Departamento",
	attrition AS "Saída",
	TO_CHAR(ROUND(AVG(percentsalaryhike),2),'FM99G99D99') || '%' AS "Média de Aumento do Salário"
FROM
	Employee_Attrition
GROUP BY attrition, department
ORDER BY department DESC


-- Média do Nível de Envolvimento no Trabalho por Saída e por Departamento
SELECT 
	department AS "Departamento",
	attrition AS "Saída",
	ROUND(AVG(jobinvolvement),2) AS "Média do Nível de Envolvimento no Trabalho"
FROM 
	Employee_Attrition
GROUP BY attrition, department
ORDER BY department


-- Análise da Taxa de Atrito nos níveis de envolvimento

SELECT 
	department AS "Departamento",
	jobinvolvement AS "Nível de Envolvimento",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Saída de Funcionários",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END)*100.00)/COUNT(*),3),
	'FM99G99D990') || '%' AS "Taxa de Atrito",
	TO_CHAR(ROUND(AVG((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END)*100.00)/COUNT(*)) 
	OVER(PARTITION BY jobinvolvement),3),'FM99G99D990') || '%' 
	AS "Média de Taxa de Atrito por Envolvimento"
FROM 
	Employee_Attrition
GROUP BY department, jobinvolvement
ORDER BY department, jobinvolvement


-- Análise descritiva sobre a idade

SELECT
	MIN(age) AS "Idade Mínima",
	MAX(age) AS "Idade Máxima",
	ROUND(AVG(age),0) AS "Idade Média"
FROM
	Employee_Attrition



-- Análise da Taxa de Atrito em relação a Frequência de Viagens

SELECT
	businesstravel AS "Frequência de Viagens",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00) / COUNT(businesstravel),2)
	,'FM99G99D990') || '%' AS "Taxa de Atrito"	
FROM
	Employee_Attrition
GROUP BY businesstravel
ORDER BY "Frequência de Viagens"
	


-- Análise da Taxa de Atrito em função da Faixa Etária

SELECT
	"Faixa Etária",
	COALESCE(COUNT(*),0) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00)/COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"

FROM(
	 SELECT
	 	CASE
	 		WHEN age BETWEEN 18 AND 29 THEN '18-29'
	 		WHEN age BETWEEN 30 AND 39 THEN '30-39'
	 		WHEN age BETWEEN 40 AND 59 THEN '40-59'
	 		WHEN age >= 60 THEN '60 ou mais'	
	    END AS "Faixa Etária",
	 	age,
	 	attrition
	  FROM
	      Employee_Attrition
 )	
GROUP BY "Faixa Etária"
ORDER BY "Faixa Etária"



-- Análise da Taxa de Atrito em função da Faixa Etária e Viagens a Trabalho

SELECT
	"Faixa Etária",
	businesstravel,
	COALESCE(COUNT(*),0) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00)/COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"

FROM(
	 SELECT
	 	CASE
	 		WHEN age BETWEEN 18 AND 29 THEN '18-29'
	 		WHEN age BETWEEN 30 AND 39 THEN '30-39'
	 		WHEN age BETWEEN 40 AND 59 THEN '40-59'
	 		WHEN age >= 60 THEN '60 ou mais'	
	    END AS "Faixa Etária",
	 	age,
	 	attrition,
		businesstravel
	  FROM
	  	  Employee_Attrition
 )	
GROUP BY "Faixa Etária", businesstravel
ORDER BY "Faixa Etária", businesstravel



-- Análise Descritiva da Distância de Casa

SELECT 
	MIN(distancefromhome) || ' km' AS "Distância Mínima",
	MAX(distancefromhome) || ' km' AS "Distância Máxima",
	TO_CHAR(ROUND(AVG(distancefromhome),3),'FM99G990D909') || ' km' AS "Distância Média"
FROM
	Employee_Attrition



-- Análise da Taxa de Atrito conforme a Faixa de Distância de Casa

SELECT
	"Distância de Casa" ||' km' AS "Distância de Casa",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00)/COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM (
	SELECT
		CASE
			WHEN distancefromhome BETWEEN 1 AND 5 THEN '1-5'
			WHEN distancefromhome BETWEEN 6 AND 10 THEN '6-10'
			WHEN distancefromhome BETWEEN 11 AND 20 THEN '11-20'
			WHEN distancefromhome BETWEEN 21 AND 29 THEN '21-29'
		END AS "Distância de Casa",
		distancefromhome,
		attrition
	FROM
		Employee_Attrition	
)
GROUP BY "Distância de Casa"
ORDER BY CAST(SUBSTRING("Distância de Casa" FROM 1 FOR (POSITION('-' IN "Distância de Casa")-1)) AS INT)



-- Taxa de Atrito por Estado Civil

SELECT
	maritalstatus AS "Estado Civil",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00) / COUNT(*),2),'FM99G990D909')
	|| '%' AS "Taxa de Atrito"
FROM
	Employee_Attrition
GROUP BY maritalstatus
ORDER BY "Taxa de Atrito"



-- Taxa de Atrito por Gênero

SELECT
	gender AS "Gênero",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00) / COUNT(*),2),
	'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM
	Employee_Attrition
GROUP BY gender
ORDER BY "Taxa de Atrito"



-- Taxa de Atrito por Estado Civil e Gênero

SELECT
	maritalstatus AS "Estado Civil",
	gender AS "Gênero",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00) / COUNT(*),2),
	'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM
	Employee_Attrition
GROUP BY gender, maritalstatus
ORDER BY maritalstatus, gender



-- Criação da Tabela Education para auxiliar a visualização das análises

CREATE TABLE Education 
( educationlevel INT PRIMARY KEY,
  educationdescription VARCHAR(50)
);

-- Inserção dos dados para as respectivas descrições de educação nos níveis de educação

INSERT INTO Education (educationlevel, educationdescription)
VALUES 
	(1, 'Ensino Médio'),
	(2, 'Curso Técnico'),
	(3, 'Graduação'),
	(4, 'Mestrado'),
	(5, 'Doutorado');




-- Taxa de Atrito por Nível de Educação

SELECT
	ED.educationlevel AS "Nível de Educação",
	ED.educationdescription AS "Descrição do Nível de Educação",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00) / COUNT(*),2),
	'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM
	Employee_Attrition AS EA
INNER JOIN Education AS ED
ON Ed.educationlevel = EA.education 
GROUP BY ED.educationdescription, ED.educationlevel
ORDER BY ED.educationlevel


-- Análise Descritiva sobre o Tempo na Empresa

SELECT
	MIN(yearsatcompany) || ' anos' AS "Menor Tempo na Empresa",
	MAX(yearsatcompany) || ' anos' AS "Maior Tempo na Empresa",
	ROUND(AVG(yearsatcompany),1) || ' anos' AS "Média de Tempo na Empresa"
FROM
	Employee_Attrition	



-- Taxa de Atrito por Faixa de Tempo na Empresa

SELECT
	"Tempo na Empresa" || ' anos' AS "Tempo na Empresa",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00) / COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM(
	SELECT
		CASE
			WHEN yearsatcompany BETWEEN 0 AND 3 THEN '00-03'
			WHEN yearsatcompany BETWEEN 3 AND 10 THEN '03-10'
			WHEN yearsatcompany BETWEEN 11 AND 20 THEN '11-20'
			WHEN yearsatcompany BETWEEN 21 AND 30 THEN '21-30'
			WHEN yearsatcompany BETWEEN 31 AND 40 THEN '31-40'
		END AS "Tempo na Empresa",
		yearsatcompany,
		attrition
	FROM
		Employee_Attrition
)
GROUP BY "Tempo na Empresa"
ORDER BY "Tempo na Empresa"


-- Análise Descritiva do Tempo da Última Promoção

SELECT
	MIN(yearssincelastpromotion) || ' anos' AS "Tempo Mínimo",
	MAX(yearssincelastpromotion) || ' anos' AS "Tempo Máximo", 
	ROUND(AVG(yearssincelastpromotion),1) || ' anos' AS "Tempo Médio"
FROM
	Employee_Attrition



-- Taxa de Atrito pela Última Promoção conforme seu Tempo na Empresa

SELECT
	"Última Promoção" ||' anos' AS "Última Promoção",
	"Tempo na Empresa" || ' anos' AS "Tempo na Empresa",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00)/COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM (
	SELECT
		CASE
			WHEN yearssincelastpromotion BETWEEN 0 AND 2 THEN '00-02'
			WHEN yearssincelastpromotion BETWEEN 3 AND 5 THEN '03-05'
			WHEN yearssincelastpromotion BETWEEN 6 AND 10 THEN '06-10'
			WHEN yearssincelastpromotion BETWEEN 11 AND 15 THEN '11-15'
		END AS "Última Promoção",
		yearssincelastpromotion,
		CASE
			WHEN yearsatcompany BETWEEN 0 AND 3 THEN '00-03'
			WHEN yearsatcompany BETWEEN 3 AND 10 THEN '03-10'
			WHEN yearsatcompany BETWEEN 11 AND 20 THEN '11-20'
			WHEN yearsatcompany BETWEEN 21 AND 30 THEN '21-30'
			WHEN yearsatcompany BETWEEN 31 AND 40 THEN '31-40'
		END AS "Tempo na Empresa",
		attrition
	FROM
		Employee_Attrition	
)
GROUP BY "Última Promoção", "Tempo na Empresa"
ORDER BY "Última Promoção", "Tempo na Empresa"



-- Taxa de Atrito por Treinamentos no Último Ano

SELECT
	trainingtimeslastyear AS "Treinamentos no Último Ano",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00)/COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM
	Employee_Attrition
GROUP BY trainingtimeslastyear
ORDER BY trainingtimeslastyear


-- Taxa de Atrito por Departamento e Treinamentos no Último Ano

SELECT
	department AS "Departamento",
	trainingtimeslastyear AS "Treinamentos no Último Ano",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00)/COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM
	Employee_Attrition
GROUP BY trainingtimeslastyear, department
ORDER BY department, trainingtimeslastyear



-- Análise da Taxa de Atrito conforme Cargo e Nível do Cargo

SELECT
	jobrole AS "Cargo", 
	joblevel AS "Nível do Cargo",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00)/COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM
	Employee_Attrition 
GROUP BY jobrole, joblevel



-- Análise da Taxa de Atrito conforme Cargo, Nível do Cargo e Departamento

SELECT
	department AS "Departamento",
	jobrole AS "Cargo", 
	joblevel AS "Nível do Cargo",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00)/COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM
	Employee_Attrition 
GROUP BY department, jobrole, joblevel
ORDER BY department, jobrole, joblevel
ORDER BY  jobrole, joblevel


-- Taxa de Atrito em relação ao Equilíbrio entre Vida Pessoal e Trabalho

SELECT
	worklifebalance AS "Equilíbrio Vida Pessoal e Trabalho",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00)/COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM
	Employee_Attrition
GROUP BY worklifebalance
ORDER BY worklifebalance



-- Taxa de Atrito em relação ao Equilíbrio Vida Pessoal e Trabalho e Envolvimento no trabalho

SELECT
	worklifebalance AS "Equilíbrio Vida Pessoal e Trabalho",
	jobinvolvement AS "Envolvimento no Trabalho",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00)/COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"
FROM
	Employee_Attrition	
GROUP BY worklifebalance, jobinvolvement
ORDER BY worklifebalance, jobinvolvement



-- Total de Funcionários para Equilíbrio de Vida Pessoal e Trabalho...
-- ...com Envolvimento no Trabalho "Ideal" (4) e sua Porcentagem de Funcionários

SELECT
	worklifebalance AS "Equilíbrio Vida Pessoal e Trabalho",
	jobinvolvement AS "Envolvimento no Trabalho",
	COUNT(*) AS "Número de Funcionários",
	(SELECT COUNT(worklifebalance)FROM Employee_Attrition 
	 WHERE jobinvolvement = 4) AS "Total Funcionários com Envolvimento = 4",
	TO_CHAR(ROUND((COUNT(*) * 100.00) / (SELECT COUNT(worklifebalance)FROM Employee_Attrition
	WHERE jobinvolvement = 4),2),'FM99G990D909') || '%' AS "Porcentagem de Funcionários"
FROM
	Employee_Attrition
WHERE
	jobinvolvement = 4
GROUP BY jobinvolvement, worklifebalance
ORDER BY worklifebalance, jobinvolvement



-- Total de Funcionários para Equilíbrio de Vida Pessoal e Trabalho...
-- ...com Equilíbrio "Ideal" (4) e sua Porcentagem de Funcionários

SELECT
	jobinvolvement AS "Envolvimento no Trabalho",
	worklifebalance AS "Equilíbrio Vida Pessoal e Trabalho",
	COUNT(*) AS "Número de Funcionários",
	(SELECT COUNT(worklifebalance)FROM Employee_Attrition 
	 WHERE worklifebalance = 4) AS "Total Funcionários com Equilíbrio = 4",
	TO_CHAR(ROUND((COUNT(*) * 100.00) / (SELECT COUNT(worklifebalance)FROM Employee_Attrition
	WHERE worklifebalance = 4),2),'FM99G990D909') || '%' AS "Porcentagem de Funcionários"
FROM
	Employee_Attrition
WHERE
	worklifebalance = 4
GROUP BY jobinvolvement, worklifebalance
ORDER BY jobinvolvement, worklifebalance



-- Taxa de Atrito em relação ao número de Empresas Trabalhadas

SELECT
	"Empresas Trabalhadas" AS "Empresas Trabalhadas",
	COUNT(*) AS "Total de Funcionários",
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS "Funcionários que Saíram",
	TO_CHAR(ROUND((SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.00)/COUNT(*),2)
	,'FM99G990D909') || '%' AS "Taxa de Atrito"

FROM(
	SELECT
		CASE
			WHEN numcompaniesworked BETWEEN 0 AND 4 THEN '00-04'
			WHEN numcompaniesworked BETWEEN 5 AND 9 THEN '05-09'
		END AS "Empresas Trabalhadas",
		numcompaniesworked,
		attrition
	FROM
		Employee_Attrition
)
GROUP BY "Empresas Trabalhadas"
ORDER BY "Empresas Trabalhadas"