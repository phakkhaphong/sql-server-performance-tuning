# Workload Scripts สำหรับ Demo Scripts

## Module 06: Statistics and Index Internals

### 1. `00_Workload_Index_Fragmentation.sql`
**สำหรับ:** `01_Index_Fragmentation.sql`

**วิธีใช้:**
1. เปิด Query Window ใหม่ (Session A)
2. รัน `00_Workload_Index_Fragmentation.sql` ใน Session A
3. รอ 2-3 นาทีให้ workload สร้าง fragmentation
4. เปิด Query Window อีกอัน (Session B)
5. รัน `01_Index_Fragmentation.sql` ใน Session B
6. สังเกตค่า `avg_fragmentation_in_percent` และ `page_count`
7. หยุด workload โดยกด Cancel ใน Session A

**สิ่งที่ควรเห็น:**
- `avg_fragmentation_in_percent` > 0 สำหรับตาราง `DemoFragmentationTable`
- Fragmentation เกิดจาก INSERT, UPDATE, DELETE แบบ random
- `page_count` เพิ่มขึ้นเมื่อมีข้อมูลมากขึ้น

**หมายเหตุ:**
- Workload จะสร้างตาราง `DemoFragmentationTable` และ index `IX_DemoFragmentationTable_RandomValue` อัตโนมัติ
- หลังเสร็จแล้ว สามารถ rebuild index: `ALTER INDEX ALL ON DemoFragmentationTable REBUILD;`

---

### 2. `00_Workload_Missing_Indexes.sql`
**สำหรับ:** `02_Missing_Indexes.sql`

**วิธีใช้:**
1. เปิด Query Window ใหม่ (Session A)
2. รัน `00_Workload_Missing_Indexes.sql` ใน Session A
3. รอ 1-2 นาทีให้ workload สร้าง missing index recommendations
4. เปิด Query Window อีกอัน (Session B)
5. รัน `02_Missing_Indexes.sql` ใน Session B
6. สังเกต missing index recommendations
7. หยุด workload โดยกด Cancel ใน Session A

**สิ่งที่ควรเห็น:**
- Missing index recommendations จาก Query Optimizer
- `avg_total_user_cost` และ `avg_user_impact` แสดงประโยชน์ของ index
- `Create Statement` แสดง SQL สำหรับสร้าง index

**หมายเหตุ:**
- Missing index recommendations จะสะสมใน `sys.dm_db_missing_index_*` DMVs
- ควรวิเคราะห์ recommendations ก่อนสร้าง index จริง (อาจมี overlapping indexes)

