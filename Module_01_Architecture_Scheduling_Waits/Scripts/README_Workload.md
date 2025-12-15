# Workload Scripts สำหรับ Demo Scripts

## วิธีใช้งาน

Scripts ที่ขึ้นต้นด้วย `00_Workload_` เป็น workload generators สำหรับสร้างกิจกรรมในระบบ เพื่อให้ Demo Scripts แสดงผลข้อมูลที่มีความหมาย

### Module 01: Architecture, Scheduling, and Waits

#### 1. `00_Workload_CPU_Stress.sql`
**สำหรับ:** `01_Check_Schedulers.sql`

**วิธีใช้:**
1. เปิด Query Window ใหม่ (Session A)
2. รัน `00_Workload_CPU_Stress.sql` ใน Session A
3. เปิด Query Window อีกอัน (Session B)
4. รัน `01_Check_Schedulers.sql` ใน Session B
5. สังเกตค่า `runnable_tasks_count` ที่จะ > 0 เมื่อมี CPU pressure
6. หยุด workload โดยกด Cancel ใน Session A

**สิ่งที่ควรเห็น:**
- `runnable_tasks_count` > 0 บ่งชี้ CPU pressure
- `current_tasks_count` และ `active_workers_count` เพิ่มขึ้น

---

#### 2. `00_Workload_Mixed_Waits.sql`
**สำหรับ:** `02_Wait_Stats_Analysis.sql`

**วิธีใช้:**
1. รัน `00_Workload_Mixed_Waits.sql` ใน Session A
2. รอ 1-2 นาทีให้ workload สร้าง wait statistics
3. รัน `02_Wait_Stats_Analysis.sql` ใน Session B
4. สังเกต wait types ต่างๆ เช่น `PAGEIOLATCH_*`, `LCK_M_*`, `CXPACKET`, `ASYNC_NETWORK_IO`

**สิ่งที่ควรเห็น:**
- Wait types หลากหลายตาม workload pattern
- Resource waits vs Signal waits
- Top wait types ที่มี percentage สูง

---

#### 3. `00_Workload_Active_Queries.sql`
**สำหรับ:** `03_Current_Executing_Requests.sql`

**วิธีใช้:**
1. รัน `00_Workload_Active_Queries.sql` ใน Session A
2. รัน `03_Current_Executing_Requests.sql` ใน Session B ทันที
3. สังเกต active requests, wait types, และ query text

**สิ่งที่ควรเห็น:**
- Active requests ที่กำลังทำงาน
- Wait types ของแต่ละ request
- Query text และ execution plan

---

## หมายเหตุ

- **Duration:** Workload scripts ตั้งค่าให้รัน 5 นาที (300 วินาที) สามารถปรับค่า `@Duration` ได้
- **Database:** เปลี่ยน `USE AdventureWorks2019;` เป็น database ของคุณ
- **Stop Workload:** กด Cancel หรือปิด Query Window เพื่อหยุด workload
- **Resource Usage:** Workload scripts ใช้ CPU, Memory, และ I/O ควรรันใน test environment

