Select count(*) from dbo.BSAK_Payment_Voucher;
Select count(*) from dbo.BSEG_Invoice;
Select count(*) from dbo.BSEG_Payment_Voucher;
Select count(*) from dbo.BSEG_VAT;
Select count(*) from dbo.WHT_Amt;
Select count(*) from dbo.tbPaymentDocument;
/*	
delete from dbo.BSAK_Payment_Voucher
delete from dbo.BSEG_Invoice
delete from dbo.BSEG_Payment_Voucher
delete from dbo.BSEG_VAT
delete from dbo.WHT_Amt
delete from dbo.tbPaymentDocument

select * from dbo.tbPaymentDocument
select * from dbo.WHT_Amt

-- UPDATE dbo.WHT_Amt SET Wtaxbat = 4236881.90 , Withholdingtaxamnt = 127106.40  WHERE DocumentNo = '1500003367' AND Itm = '002'
-- select Wtaxbat, Withholdingtaxamnt from dbo.WHT_Amt WHERE DocumentNo = '1500003367' AND Itm = '002'
*/