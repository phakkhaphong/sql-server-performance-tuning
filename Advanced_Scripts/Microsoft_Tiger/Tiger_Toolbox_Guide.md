# Microsoft SQL Server Tiger Toolbox (ฉบับภาษาไทย)

โฟลเดอร์นี้รวบรวมข้อมูลและคู่มือการใช้งานเครื่องมือ **Advanced Performance Tools** ที่จัดทำโดยทีม **Microsoft SQL Server Tiger Team** (ทีมวิศวกรผู้อยู่เบื้องหลังการพัฒนา SQL Server)

**แหล่งข้อมูลหลัก**: [GitHub: microsoft/tigertoolbox](https://github.com/microsoft/tigertoolbox)

---

## 1. BPCheck (Best Practice Check)
**วัตถุประสงค์**: ใช้สำหรับตรวจสอบ SQL Server Instance ว่ามีการตั้งค่าตาม Best Practices หรือไม่ เครื่องมือนี้คล้ายกับ Best Practice Analyzer (BPA) ในอดีต แต่มีความทันสมัยและเบากว่า (Lightweight)

### ความเข้ากันได้ (Compatibility)
*   **SQL Server**: รองรับตั้งแต่เวอร์ชัน **2005 จนถึง 2022+**
*   **Cloud**: รองรับ Azure SQL Database Managed Instance

### วิธีการใช้งาน
1.  **Download**: ดาวน์โหลดไฟล์ `BPCheck.sql` หรือ PowerShell script จาก [BPCheck Folder](https://github.com/microsoft/tigertoolbox/tree/master/BPCheck)
2.  **Execute**: รัน SQL script ผ่าน SSMS หรือใช้ PowerShell
3.  **Result**: ระบบจะรายงาน "Issues" ที่ตรวจพบ (เช่น ตั้งค่า MaxDOP ผิด, ค่า Cost Threshold ต่ำเกินไป, หรือสิทธิ์ของ Service Account ไม่ถูกต้อง)

---

## 2. Waits and Latches (Waits_and_Latches)
**วัตถุประสงค์**: ชุด Scripts สำหรับวิเคราะห์ Wait Statistics และ Latch Contention แบบเจาะลึก

### ความเข้ากันได้ (Compatibility)
*   **SQL Server**: รองรับทุกเวอร์ชัน (Script จะทำการกรอง Wait Type ที่เป็น System/Benign ออกให้อัตโนมัติ)

### Key Scripts
*   **usp_BJ_CheckWaitStats.sql**: สคริปต์วิเคราะห์ Wait Stats คล้ายกับของ Paul Randal แต่ได้รับการดูแลโดย Microsoft โดยตรง
*   **Latch Contention**: สคริปต์สำหรับหาว่า "Page ไหน" ที่กำลังเกิดปัญหา `PAGELATCH_XX` (แย่งกันเขียนหน้าข้อมูลเดียวกัน)

### วิธีการใช้งาน
1.  เข้าไปที่ [Waits_and_Latches](https://github.com/microsoft/tigertoolbox/tree/master/Waits-and-Latches)
2.  Copy เนื้อหา Script
3.  รันใน SSMS ระหว่างที่ระบบกำลังช้า

---

## 3. SQL Query Stress (ข้อแนะนำจากทีม Tiger)
แม้จะไม่ได้อยู่ใน Repo นี้โดยตรง แต่ทีม Tiger มักแนะนำให้ใช้ **ostress** (จาก RML Utilities ของ Microsoft เอง) หรือ **SQLQueryStress** (จาก Adam Machanic/Erik Darling) ในการจำลอง Workload เพื่อทดสอบ Performance

### ความเข้ากันได้
*   ใช้ได้กับ SQL Server ทุกเวอร์ชัน

---

## 4. Maintenance Solution
สำหรับเรื่องการทำ Index Maintenance และ Backups:
*   **Adaptive Index Defrag**: ทีม Tiger มีเครื่องมือชื่อ [AdaptiveIndexDefrag](https://github.com/microsoft/tigertoolbox/tree/master/AdaptiveIndexDefrag) ที่ฉลาดมากในการเลือก Reorganize/Rebuild
*   **Industry Standard**: อย่างไรก็ตาม ในหลายกรณี Microsoft PFE (Premier Field Engineer) มักจะแนะนำ **Ola Hallengren's Solution** ซึ่งเป็นมาตรฐานอุตสาหกรรม

### ความเข้ากันได้
*   **AdaptiveIndexDefrag**: SQL Server 2008 R2 - 2022+
*   **Ola Hallengren**: SQL Server 2008 - 2022+

---

> **คำเตือน**: สคริปต์เหล่านี้เป็นแบบ "As-Is" (ใช้ตามสภาพ) ควรทดสอบในระบบ Test (Non-Production) ก่อนนำไปรันบนเครื่อง Production เสมอ
