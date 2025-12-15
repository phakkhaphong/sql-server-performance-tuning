# Workload Scripts สำหรับ Demo Scripts

## Module 02: I/O

### `00_Workload_IO_Activity.sql`
**สำหรับ:** `01_Virtual_File_Stats.sql`

**วิธีใช้:**
1. เปิด Query Window ใหม่ (Session A)
2. รัน `00_Workload_IO_Activity.sql` ใน Session A
3. รอ 1-2 นาทีให้ workload สร้าง I/O activity
4. เปิด Query Window อีกอัน (Session B)
5. รัน `01_Virtual_File_Stats.sql` ใน Session B
6. สังเกตค่า I/O latency, total reads/writes
7. หยุด workload โดยกด Cancel ใน Session A

**สิ่งที่ควรเห็น:**
- `Avg Read Latency (ms)` และ `Avg Write Latency (ms)` > 0
- `Total Reads` และ `Total Writes` เพิ่มขึ้น
- Latency ตามเกณฑ์:
  - < 5ms: Excellent
  - 5-10ms: Good
  - 10-20ms: Acceptable
  - > 20ms: Poor (Investigate storage)

**หมายเหตุ:**
- หากต้องการ force physical I/O (ไม่ใช่ logical reads จาก buffer pool) สามารถ uncomment `DBCC DROPCLEANBUFFERS;` ใน workload script (ใช้ด้วยความระมัดระวัง!)

