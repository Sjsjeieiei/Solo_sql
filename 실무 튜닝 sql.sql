# 3장
-- 드라이빙 테이블: 조인연산에서 기준이되는 테이블 운전자
-- 드리븐 테이블 드리븐 테이블은 조인 연산에서 드라이븡 테이블에 의해 끌려가는 테이블 = 끌려가는 자동차
-- 옵티마이저는 데이터베이스 관리 시스템(DBMS)에 내장된 기능으로, 사용자가 작성한 쿼리를 실행하는 가장 효율적인 방법을 결정합니다.
-- 이것은 DBMS가 데이터 액세스 경로를 선택하고 실행 계획을 생성하는 프로세스를 의미합니다. 옵티마이저는 쿼리를 실행하기 위해 다음과 같은 작업을 수행합니다:
-- expalin: 실행순서 분석
-- id: 쿼리의 실행 순서를 나타내는 일련번호입니다.
-- select_type: 쿼리의 유형을 나타냅니다. 예를 들어, 단순한 쿼리인지 서브쿼리인지 등을 표시합니다.
-- table: 테이블 이름입니다.
-- type: 테이블 액세스 방법을 나타냅니다. 예를 들어, ALL이면 전체 테이블 스캔을 의미하고, index면 인덱스를 사용한 액세스를 의미합니다.
-- possible_keys: 옵티마이저가 고려한 가능한 인덱스 목록입니다.
-- key: 실제로 사용된 인덱스입니다.
-- key_len: 사용된 인덱스의 길이입니다.
-- ref: 키를 참조하는 테이블과 열입니다.
-- rows: 예상되는 행 수입니다.
-- Extra: 추가 정보가 포함될 수 있습니다. 예를 들어, Using where는 WHERE 절이 사용되었음을 나타냅니다.
USE tuning;explain
SELECT 사원.사원번호,
       사원.이름,
       사원.성,
       (
              SELECT max(부서번호)
              FROM   부서사원_매핑 AS 매핑
              WHERE  매핑.사원번호=사원.사원번호 ) 카운트
FROM   사원
WHERE  사원.사원번호 =100001;explain
SELECT 사원1.사원번호,
       사원1.이름,
       사원1.성
FROM   사원 AS 사원1
WHERE  사원1.사원번호 =100001
UNION ALL
SELECT 사원2.사원번호,
       사원2.이름,
       사원2.성
FROM   사원 AS 사원2
WHERE  사원2.사원번호 = 100002;

# 서브쿼리explain
SELECT
       (
              SELECT count(*)
              FROM   부서사원_매핑 AS 사원 ) AS 카운트,
       (
              SELECT max(연봉)
              FROM   급여 ) AS 급여;

# derivedEXPLAIN
SELECT     사원.사원번호,
           급여.연봉
FROM       사원
INNER JOIN
           (
                    SELECT   사원번호,
                             max(연봉) AS 연봉
                    FROM     급여
                    WHERE    사원번호 BETWEEN 10001 AND      20000
                    GROUP BY 사원번호 ) AS 급여
ON         사원.사원번호 = 급여.사원번호;#
UNION
      -- explain
      -- # primary
      -- select 'M' as 성별,max(입사일자) as 입사일자
      -- from 사원 as 사원1
      -- where 성별 = 'M'
      -- union all
      -- select 'M' as 성별,max(입사일자) as 입사일자
      --  from 사원 as 사원1
      --     where 성별 ='M'
      #
UNION
      result EXPLAIN
SELECT 'M'               AS 성별,
       max(입사일자) AS 입사일자
FROM   사원
WHERE  성별 = 'M'
UNION
SELECT 'F'               AS 성별,
       min(입사일자) AS 입사일자
FROM   사원
WHERE  성별 = 'F';

# DEPENDENT SUBQUERY
# 메인쿼리에서 AND 사원1.사원번호 = 관리자.사원번호 연결점 값을 지속적으로 값을 전달받는 구조.
-- explain
--  select 관리자.부서번호,
--   (select 사원1.이름
--   from 사원 as 사원1
--         where 성별 ='F'
--    and  사원1.사원번호 = 관리자.사원번호
--
--   union all
--
--         select  사원2.이름
--         from 사원 as 사원2
--         where 성별 ='M'
--    and 사원2.사원번호 = 관리자.사원번호
--             ) as 이름
--             from 부서관리자 as 관리자
--#DEPENDENT
UNION
      -- union으로 연결된 단위 쿼리 중 첫 번쨰 단위의 쿼리를 제외한 두 분쨰 단위쿼리에 해당하는 경우이다.
      -- union으로 연결된 두 번쨰 이후의 단위 쿼리가 독립적으로 수행하지 못하고 메인테이블로 부터
      -- and 사원1.사원번호 = 관리자.사원번호 값을 공급받기에 튜닝이 필요하며 성능적으로 우수하지 못하다.
      EXPLAIN
SELECT 관리자.부서번호,
       (
              SELECT 사원1.이름
              FROM   사원 AS 사원1
              WHERE  성별 ='F'
              AND    사원1.사원번호 = 관리자.사원번호
              UNION ALL
              SELECT 사원2.이름
              FROM   사원 AS 사원2
              WHERE  성별 ='M'
              AND    사원2.사원번호 = 관리자.사원번호 ) AS 이름
FROM   부서관리자                                               AS 관리자;#uncacheable suquery
-- 단어 그대로 메모리에 상주하여 재활용되어야 할 서브쿼리가 재상요되지 못할 떄 출력되는 유형이다.
-- 해당 서브쿼리 안에 사용자 정의 함수나 사용자 변수가 포함되거나
-- rand() uuid 함수등을 사용하여 매번 조회시마다 결과가 달라지는 경우에 해당.
-- rand: 무작위 uuid : 고유값 생성.
EXPLAIN
SELECT *
FROM   사원
WHERE  사원번호 =
       (
              SELECT round(rand() * 1000000));

# MATERIALIZED
-- in 절에 구문에 견결된 서브쿼리가 임시 테이블을 생성한뒤 조인이나 가공 작업을
-- 수행할떄 출력되는 유형 in절의 서브쿼리를 임시 테이블로 만들어서 조인 작업을 수행하는것explain
SELECT *
FROM   사원
WHERE  사원번호 IN
       (
              SELECT 사원번호
              FROM   급여
              WHERE  시작일자> '2020-01-01');

# 조회 데이터가 단 한건일떄 출력되는 유형.explain
SELECT *
FROM   사원
WHERE  사원번호 =100001;

# eq_ref
-- 조인시 드리븐 테이블의 데이터에 접근하여 고유인덱스 또는 기본키로 단 1건의 데이터를 조회하는 방식입닏.
-- 드라이빙 테이블과의 조인 키가 드리븐 테이블에 유일하므로 조인이 수행될 떄 성능상 가장 유리한 경우라고 할 수 있다.explain
SELECT 매핑.사원번호,
       부서.부서번호,
       부서.부서명
FROM   부서사원_매핑 AS 매핑,
       부서
WHERE  매핑.부서번호 = 부서.부서번호
AND    매핑.사원번호 BETWEEN 100001 AND    1000010;#ref 조인을 수행시 드리븐테이블의 접근 범위가 2개이상일 경우를 의미합니다.
EXPLAIN
SELECT 사원.사원번호,
       직급.직급명
FROM   사원,
       직급
WHERE  사원.사원번호 = 직급.사원번호
AND    사원.사원번호 BETWEEN 10001 AND    10100;explain
SELECT *
FROM   사원
WHERE  입사일자 ='1985-11-21';#ref 유형과 유사하나 IS NULL 구문에 대해 인덱스를 활용하도록 최적화된 방식이다.
-- mysql과 mariajdb는 null에 대해서 인덱스 검색이 가능하다 이경우 null이 가장 앞에 위치함.
EXPLAIN
SELECT *
FROM   사원출입기록
WHERE  출입문 IS NULL
OR     출입문 ='A';#range
-- 테이블 내의 연속된 데이터 범위를 조회하는 유형이다 = <> >= < <= 과 같은 비교연산자와
-- is null <=> betwenn 또는 in연산을 통해 범위를 스캔하는 방식이다.
-- 스캔 범위량이 넓다면 성능저하의 요잉ㄴ이 될 수 있다.
EXPLAIN
SELECT *
FROM   사원
WHERE  사원번호 BETWEEN 10001 AND    100000;#fulltext
-- 텍스트 검색을 빠르게 처리하기 위해 전문 인덱스를 사용하여 데이터에 접근하는 방식
#index_merge 말 그대로 결홥된 인덱스들이 동시에 사용되는 유형입니다.
-- 특정 테이블에 두 개이상의 인덱스가 병합되어 동시에 적용됩니다. 이떄 전문 인덱스는 제외딥니다.
-- 한편 가족성을 고려하여 당장 필요하지 않는 partions ,possable_keys,filtered 정보는 설명하지 않습니다.
EXPLAIN
SELECT *
FROM   사원
WHERE  사원번호 BETWEEN 10001 AND    100000
AND    입사일자 ='1985-11-21';#index
-- type 항목의 index 윻여은 풀 스캔을 의맣ㄴ다. 즉 물리적인 인덱스 블록을 처음 부터 끝까지 훑는 방식이다. 이떄 데이터를 스캔하는 대상이 인덱사를 점이다를 뿐이다.
EXPLAIN
SELECT 사원번호
FROM   직급
WHERE  직급명 ='Manager';

# ALL
-- 테이블을 처음부터 끝까지 읽는 테이블 풀 스캔 방식에 해당되는 유형이다 ㅣall 유형은 활용 할 수 있는 인덱스가 없어지거나 인덳르릐 활용하는 게 오히려 비효율이라고 옵티마이지저가 판단 했을떄 선택됨.explain
SELECT *
FROM   사원;#possible_keys
-- 옵티마이저가 sql문을 최적화고자 사용할 수 있는 인덱스 목록을 출력한다.
-- 다만 실제 사용한 인덱스가 아닌 사용할 수 있는 후보군의 기본 키와 인덱스 모록만 보여주므로 sql 튜닝의 효율성은 없습니다.
-- key 옵티마이저가 sql문을 최적화고자 사용한 기본키 꼬는 인덱스명을 의미 어느 인덱스로부터 데이터를 검색했는지 확인할 수 있으므로 비효율적인 인데스를 사용햌ㅆ거나 인덱스자체를 사용하지 않았으므로 sql튜닝의 대상
EXPLAIN
SELECT 사원번호
FROM   직급
WHERE  직급명 ='Manager';explain
SELECT *
FROM   사원;

-- possible_keys 
-- 옵티마이저가 sql문을 최적화고자 사용할 수 있는 인덱스 목록을 추렭합니다.
-- 다만 실제 사용한 인덱스가 아닌 사용할 수 있는 후보군의 기본 키와 인덱스 목록만
-- 보여주므로 sql 튜닝의 효율성은 없어짐.

# key
-- 옵티마이저가 sql문을 최적화 하고자 할경우 사용한 기본키 또는 인덱스명읠 의미함.

explain
	select 사원번호
    from 직급
    where 직급명 ="Manager";
    

explain 
	select * from 사원
    ;
    
explain 
	select 사원번호
		from 직급
        where 직급명 = 'Manager';
        
        #ref reference의 약자로 테이블 조인을 수행할떄 어떤 조건으로 해당 테이블에 엑새스 되었는지를 알아주는 정보입니다.
	explain 
    select 사원.사원번호, 직급.직급명
    from 사원,직급
    where 사원.사원번호 = 직급.사원번호
		and 사원.사원번호 between 10001 and 10100;
        
        # rows
        -- sql문을 수행하고자 접근한느 데이터의 모든 행 수를 나타내는 예측항목입니다.
        -- 즉 디스크에서 데이터 파일을 읽고 메모리에서 처리해야할 행 수를 예상하는 값이고 수시로 변동되는 mysql의 통계 정보를 산출하여 수치가 정확하진 않는다.
        -- 최종 출력될 행수가 아니므로 주의 요먕
        
        # filterd
        -- sql문을 통해 db엔진으로 가져온 데이터 대상으로 필터 조건에 따라 어는 정도의 비율로 데이터를 제거했는지를 의미하는 항복 예를 들어 
        -- dB 엔진으로 100건의 데이터를 가져왔다고 가정한다면 이후 WHere 절의 사원번호 between 1 and 10 조건을 100건의 데이터가 10건으로 필터링됩니다. 이처럼 100건에서 10건으로 필터링 되었으므로 filtred 에는 10라는 정보과 출력될것 
        
        #extra
        -- sqlㅁ누을 어떻게 수행할 것인지에 관한 추가 정보를 보여주는 항목이다. 이러한
        -- 부가적인 정보들은 세미클론으로 구분하여 여러 가지 정보를 나열할 수 있으며 30여가지 항목으로 정리가능
        
        -- distinct (디스틴트)
        
        -- usiong where
	     -- 실행계획에서 자주 볼 수 있는 extra정보닙니다. where절의 필터 조건을 사용해 mysql엔진으로 가져온 데이터추출하는것이라는 의미
         
         #using temporary
         -- 데이터의 중간 결과를 저장하고자 임시 테이블을 생성하겠다는 의미이다. 데이터를 가져와 저장한 뒤에 정렬 작업을 수행하거나 중복을 제거하는 작업등을 수행하비낟.
         -- 보통 distinct group by,order by 구문이 포함된 경우 using temporary 정보가 출력됨.
         
         #Using index
         -- 물리적인 데이터 파일을 읽지 못하고 인덱스만을 읽어서 sql문의 요청사항을 처리할 수 있는
         -- 경우를 의미한다. 일명 커버링 인덱스 방식이라고 부르며,인덱스로 구성된 열만 sql문에서 사용할 경우 이 방식을 활용합니다.alter
         
         explain select 직급명
         from 직급
		 where 사원번호 =100000;
         
		 #explain format =Traditional 

explain format =Traditional
select *
from 사원
where 사원번호 between 100001 and 200000;

# EXPLAIN 형시값에 true 옵션을 입력하면 트리 형태로 추가된 실행 계획 항목을 확인가능
explain
	select * 
    from 사원
    where 사원번호 between 100001 and 200000;
#EXPLAIN format = json 
-- 형식값에 json 옵션을 입력하면 json형태로 추가된 실행 계획 항목을 확인가능
explain format =json
select *
from 사원
where 사원번호 between 100001 and 200000;

# 그동안 출력된 실행 계획은 예측된 실행 계획에 관한 정보이다 만약 실제 측정한 실행 계획 정보를 
# 출력하고 싶다면 ANALYZE 키웓르르 사용한다 실제 수행된 시간과 비용을 측정하여 실측 실행 계획과 예측 실행 계획 모두를 확일하려면 explain analyze키워드를 활용합니다.
explain analyze
 select *
 from 사원
 where 사원번호 between 100001 and 200000;
 
 # 파티션으로 설정된 테이블에 접근대상인 파티션의 정보를 출력합니다.
EXPLAIN PARTITIONS
SELECT * 
FROM 사원
WHERE 사원번호 BETWEEN 100001 AND 200000;

 
 #EXPLAIN EXTENDED 
EXPLAIN EXTENDED
SELECT * 
FROM 사원
WHERE 사원번호 BETWEEN 100001 AND 200000;


ANALYZE
SELECT * 
FROM 사원
WHERE 사원번호 BETWEEN 100001 AND 2000000;


# 프로파일링 문제원인 찾기
show variables like 'profiling%';
-- on 상태로 변경 
set profiling = ON;

select 사원번호
	from 사원
    where 사원번호 =100000;
    
    
    show profiles;
    
    show profile for query 1;
    
    
    -- 168 쪽