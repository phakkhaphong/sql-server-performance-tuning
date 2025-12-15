# Workload Scripts สำหรับ Demo Scripts

## Module 05: Concurrency

### `00_Workload_Blocking.sql` และ `00_Workload_Blocking_SessionB.sql`
**สำหรับ:** 
- `01_Blocking_Analysis.sql`
- `02_Active_Transactions.sql`

**วิธีใช้:**
1. เปิด Query Window ใหม่ (Session A - The Blocker)
2. รัน `00_Workload_Blocking.sql` ใน Session A
3. เปิด Query Window อีกอัน (Session B - The Victim)
4. รัน `00_Workload_Blocking_SessionB.sql` ใน Session B
5. เปิด Query Window อีกอัน (Session C - Monitor)
6. รัน `01_Blocking_Analysis.sql` ใน Session C เพื่อดู blocking chain
7. รัน `02_Active_Transactions.sql` ใน Session C เพื่อดู active transactions
8. หยุด workload โดยกด Cancel ใน Session A และ B

**สิ่งที่ควรเห็น:**

**จาก `01_Blocking_Analysis.sql`:**
- Blocked Session (Session B) ที่รอ Blocking Session (Session A)
- Wait types เช่น `LCK_M_X`, `LCK_M_S`
- Blocked Query และ Blocking Query

**จาก `02_Active_Transactions.sql`:**
- Active transactions ที่ยังไม่ commit
- Transaction duration
- Lock information

**หมายเหตุ:**
- Session A จะ hold locks เป็นเวลา 5-8 วินาทีต่อ transaction
- Session B จะพยายามเข้าถึงข้อมูลเดียวกันและถูก block
- ใช้ตาราง `DemoBlockingTable` ที่สร้างอัตโนมัติ

