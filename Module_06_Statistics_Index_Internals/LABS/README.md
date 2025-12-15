# Lab: กลยุทธ์ Indexing (Indexing Strategies)

## Prerequisites (สิ่งที่ต้องเตรียม)
- **Database**: `AdventureWorks2022`

## Scenario (สถานการณ์)
Report ดึงข้อมูลลูกค้าทำงานช้ามาก ทั้งๆ ที่เป็นการค้นหาแค่บางส่วน (Partial match)
คุณสงสัยว่าอาจเป็นเพราะ **Missing Index** หรือเกิด **Key Lookup** ที่ไม่จำเป็น

## Objectives (วัตถุประสงค์)
1.  ระบุ Missing Index Warning
2.  วิเคราะห์ความเสียหาย (Cost) ของ Key Lookups
3.  สร้าง Covering Index เพื่อแก้ปัญหาอย่างถาวร

---

## Exercise 1: Missing Index & Key Lookups

### Step 1: Baseline (Table Scan / Index Scan)
1.  เปิดไฟล์ `Scripts\01_Missing_Index.sql`
2.  เปิด "Include Actual Execution Plan" (Ctrl+M)
3.  รัน Query **Step 1**
    *   Query นี้ค้นหา `Person.Person` โดยใช้คอลัมน์ที่ไม่มี Index (เช่น `Title` หรือคอลัมน์สมมติ)
    *   **Execution Plan**: จะเห็นเป็น `Clustered Index Scan` (อ่านข้อมูลทั้งตาราง)
    *   **ข้อความสีเขียว**: `Missing Index (Impact 99.xxx%)` <-- นี่คือคำใบ้จาก SQL Server

### Step 2: ลองสร้าง Index แบบไม่สมบูรณ์ (Key Lookup)
1.  รัน **Step 2** เพื่อสร้าง Non-clustered index แบบธรรมดา
2.  รัน Query เดิมอีกครั้ง
    *   Plan เปลี่ยนเป็น: `Index Seek` + `Key Lookup` (Nested Loops)
    *   ถ้าจำนวนแถวที่ดึงมาเยอะมากๆ การทำ Lookup อาจจะ **ช้ากว่า** Scan ก็ได้ (Random I/O)

### Step 3: สร้าง Covering Index (สมบูรณ์แบบ)
1.  รัน **Step 3** เพื่อเพิ่ม `INCLUDE` columns ลงไปใน Index
2.  รัน Query เดิมอีกครั้ง
    *   Plan กลายเป็น: `Index Seek` (เพียวๆ) ไม่ต้องทำ Lookup แล้ว
    *   Reads: ลดลงมหาศาล

---

## Exercise 2: Columnstore / Advanced Index Analysis (Optional)
1.  รัน `Scripts\06_Advanced_Index_Analysis.sql`
2.  เปรียบเทียบความเร็วและลักษณะการใช้ Index ระหว่างรูปแบบต่างๆ (รวมถึงกรณี Columnstore หากมีใน Script)

---

## Exercise 3: Advanced - การวิเคราะห์ Index ด้วย Query Store
*แบบฝึกหัดขั้นสูงนี้จะใช้ `02_Index_Analysis_QueryStore.sql` เพื่อดูประวัติการใช้งาน Index*

### Concept (แนวคิด)
DMV ปกติจะรีเซ็ตเมื่อ Restart แต่ Query Store เก็บข้อมูลถาวร เราสามารถดูได้ว่า Index ไหนที่ "Missing" มานานแล้ว หรือ Index ไหนที่มีแต่คนอ่านแต่ไม่มีคนใช้

### Steps (ขั้นตอน)
1.  เปิดและรัน: `Scripts\02_Index_Analysis_QueryStore.sql`
2.  Script นี้จะดึงข้อมูลจาก Query Store เพื่อแนะนำ Missing Index โดยอิงจากประวัติการใช้งานจริง (Historical Workload) ซึ่งแม่นยำกว่าการดูจาก DMV ณ ขณะนั้น

---

## Exercise 4: ตรวจสอบและแก้ไข Out of Date Statistics
*แบบฝึกหัดนี้จะใช้ `03_Check_Stale_Stats.sql` เพื่อดูแลสุขภาพของ Statistics*

### Concept (แนวคิด)
ถ้า `modification_counter` (จำนวนแถวที่เปลี่ยน) สูงเกินไปเมื่อเทียบกับจำนวนแถวทั้งหมด (`rows`) Optimizer อาจเลือก Plan ผิด (เช่นคิดว่าตารางยังมีข้อมูลน้อย เลยเลือก Key Lookup ทั้งที่ข้อมูลบวมไปเยอะแล้ว)

### Steps (ขั้นตอน)
1.  **Generate Changes**: ลอง Insert หรือ Update ข้อมูลจำนวนมากในตารางใดตารางหนึ่ง (เช่นใช้ Script ใน Module 3)
2.  **Check Status**: รัน `Scripts\03_Check_Stale_Stats.sql`
3.  **Analyze**: ดูคอลัมน์ `Percent Changed`
    *   ถ้า > 20% แล้ว Last Updated นานมาแล้ว -> **ควร Update**
4.  **Fix**: สั่ง Update Stats
    ```sql
    UPDATE STATISTICS ชื่อตาราง;
    -- หรือเจาะจงเฉพาะตัว
    UPDATE STATISTICS ชื่อตาราง ชื่อStatistics;
    ```
5.  รัน Script ตรวจสอบอีกครั้ง `modification_counter` จะต้องกลับเป็น 0

---

## Exercise 5: ตรวจสอบและกำจัด Index ขยะ (Bad Indexes)
*แบบฝึกหัดนี้จะใช้ `05_Check_Bad_Indexes.sql` เพื่อลดภาระของระบบ*

### Concept (แนวคิด)
Index ทุกตัวที่เราสร้างคือ "ภาระ" ในการ Maintain (เมื่อมี Insert/Update) ถ้า Index ไหนโดน Update บ่อยแต่ไม่เคยโดน Read เลย (Unused) หรือ Index ไหนซ้ำซ้อนกับเพื่อน (Duplicate) ควรพิจารณาลบทิ้ง (DROP)

### Steps (ขั้นตอน)
1.  **Generate Load**: รัน Workload อะไรก็ได้เพื่อให้มีการ Update ข้อมูล
2.  **Check Status**: รัน `Scripts\05_Check_Bad_Indexes.sql`
3.  **Analyze (Part 1 - Unused)**:
    *   ดูรายการที่ `TotalReads` = 0 แต่ `user_updates` สูงๆ
    *   **Decision**: ถ้าไม่ใช่ Primary Key หรือ Unique Constraint -> **DROP** ได้เลย
4.  **Analyze (Part 2 - Duplicates)**:
    *   ดูรายการที่ `KeyCols` และ `IncludeCols` เหมือนกันเป๊ะ
    *   **Decision**: เก็บตัวนึงไว้ แล้ว **DROP** อีกตัวออกไป


