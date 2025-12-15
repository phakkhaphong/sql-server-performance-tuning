# Workload Scripts สำหรับ Demo Scripts

## Module 07: Query Execution

### 1. `00_Workload_CPU_Queries.sql`
**สำหรับ:** `01_Top_CPU_Queries.sql`

**วิธีใช้:**
1. เปิด Query Window ใหม่ (Session A)
2. รัน `00_Workload_CPU_Queries.sql` ใน Session A
3. รอ 1-2 นาทีให้ workload สร้าง CPU-intensive queries
4. เปิด Query Window อีกอัน (Session B)
5. รัน `01_Top_CPU_Queries.sql` ใน Session B
6. สังเกต Top 10 queries ที่ใช้ CPU สูงสุด
7. หยุด workload โดยกด Cancel ใน Session A

**สิ่งที่ควรเห็น:**
- Queries ที่มี `Avg CPU Time` สูง
- Query text และ execution plan
- `execution_count` และ `Avg Duration`

---

### 2. `00_Workload_IO_Queries.sql`
**สำหรับ:** `03_High_IO_Queries.sql`

**วิธีใช้:**
1. เปิด Query Window ใหม่ (Session A)
2. รัน `00_Workload_IO_Queries.sql` ใน Session A
3. รอ 1-2 นาทีให้ workload สร้าง I/O-intensive queries
4. เปิด Query Window อีกอัน (Session B)
5. รัน `03_High_IO_Queries.sql` ใน Session B
6. สังเกต Top 10 queries ที่ใช้ Logical I/O สูงสุด
7. หยุด workload โดยกด Cancel ใน Session A

**สิ่งที่ควรเห็น:**
- Queries ที่มี `Avg Logical Reads` และ `Avg Logical Writes` สูง
- Query text และ execution plan
- I/O-intensive operations เช่น table scans, large joins

---

### 3. `00_Workload_Implicit_Conversions.sql`
**สำหรับ:** `02_Find_Implicit_Conversions.sql`

**วิธีใช้:**
1. เปิด Query Window ใหม่ (Session A)
2. รัน `00_Workload_Implicit_Conversions.sql` ใน Session A
3. รอ 1-2 นาทีให้ workload สร้าง queries with implicit conversions
4. เปิด Query Window อีกอัน (Session B)
5. รัน `02_Find_Implicit_Conversions.sql` ใน Session B
6. สังเกต queries ที่มี implicit conversion warnings
7. หยุด workload โดยกด Cancel ใน Session A

**สิ่งที่ควรเห็น:**
- Queries ที่มี implicit conversions ใน execution plan
- Conversion warnings เช่น VARCHAR to NVARCHAR, INT to BIGINT
- Impact ต่อ index usage (อาจทำให้ index seek กลายเป็น scan)

**หมายเหตุ:**
- Implicit conversions มักเกิดจาก data type mismatch ระหว่าง column และ parameter/literal
- ควรแก้ไขโดยใช้ data type ที่ตรงกัน

