--alter Procedure Pro_GEN_Bankfile as
DECLARE @H_CoCd varchar(4)
DECLARE @H_Amount DECIMAL(18,2)
DECLARE @H_ChqCount INT

DECLARE @D_TaxCount INT
DECLARE @CountWHTNo INT
DECLARE @LoopINV INT
DECLARE @BeneRef varchar(16)
DECLARE @INVType varchar(5)
DECLARE @INVSign varchar(1)
DECLARE @TaxSeq INT

DECLARE @SI_ExcVATAmt DECIMAL(18,2)
DECLARE @SI_VATAmt DECIMAL(18,2)
DECLARE @SI_TAXAmt DECIMAL(18,2)

DECLARE @Cl	varchar(510)
DECLARE @CoCd	varchar(510)
DECLARE @DocumentNo	varchar(510)
DECLARE @Year	varchar(510)
DECLARE @Itm	varchar(510)
DECLARE @Clearing	varchar(510)
DECLARE @ClgEntDate	varchar(510)
DECLARE @Clrngdoc	varchar(510)
DECLARE @PK	varchar(510)
DECLARE @DC	varchar(510)
DECLARE @WT	varchar(510)
DECLARE @AmountinLC	DECIMAL(18,2)
DECLARE @Curr	varchar(510)
DECLARE @Withhldtaxbase	DECIMAL(18,2)
DECLARE @GL	varchar(510)
DECLARE @Customer	varchar(510)
DECLARE @Vendor	varchar(510)

DECLARE @TaxID	varchar(510)
DECLARE @VendorCode 	varchar(510)
DECLARE @Name	varchar(510)
DECLARE @Address	varchar(510)
DECLARE @Fax	varchar(510)
DECLARE @Tel	varchar(510)
DECLARE @PND	varchar(510)
DECLARE @VATRegisNo	varchar(510)
DECLARE @TaxIDVendor3 varchar(510)


DECLARE @V_TaxID	varchar(510)
DECLARE @V_VendorCode 	varchar(510)
DECLARE @V_Name	varchar(510)
DECLARE @V_Address	varchar(510)
DECLARE @V_Fax	varchar(510)
DECLARE @V_Tel	varchar(510)
DECLARE @V_PND	varchar(510)
DECLARE @V_VATRegisNo	varchar(510)
DECLARE @V_TaxIDVendor3	varchar(510)

DECLARE @CHQDATE	varchar(10)
DECLARE @PrintData	varchar(max)
DECLARE @PrintData2	varchar(max)

DECLARE @T_DocumentNo	varchar(510)
DECLARE @T_Withhldtaxtype	varchar(510)
DECLARE @T_Wtaxbat	DECIMAL(18,2)
DECLARE @T_Withholdingtaxamnt	DECIMAL(18,2)
DECLARE @T_Wtaxrate	DECIMAL(18,2)
DECLARE @T_Loop	INT

DECLARE @TD_DocumentNo	varchar(510)
DECLARE @TD_WTaxrate	DECIMAL(18,2)
DECLARE @TD_Withhldtaxtype	varchar(510)
DECLARE @TD_Amount	DECIMAL(18,2)


DECLARE @I_Reference	varchar(510)
DECLARE @I_DocumentNo	varchar(510)
DECLARE @I_DocDate	varchar(510)
DECLARE @I_DocYear	varchar(510)
DECLARE @I_ExcVATAmt	DECIMAL(18,2)
DECLARE @I_VATAmt	DECIMAL(18,2)
DECLARE @I_TAXAmt	DECIMAL(18,2)
DECLARE @I_ShowInvoice varchar(510)

DECLARE @OT_DocumentNo varchar(510)
DECLARE @OT_GL varchar(510)
DECLARE @OT_Amount DECIMAL(18,2)

--DECLARE @C_DocumentNo varchar(510)
DECLARE @C_Customer varchar(510)
DECLARE @C_Amount DECIMAL(18,2)

DECLARE @NewLineChar AS CHAR(2) 
SET @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @SP_Clrngdoc varchar(510)
DECLARE @SP_ExcVATAmt DECIMAL(18,2)
DECLARE @SP_VATAmt DECIMAL(18,2)
DECLARE @SP_TAXAmt DECIMAL(18,2)
DECLARE @SP_Withholdingtaxamnt DECIMAL(18,2)
DECLARE @SP_OtherTaxAmt DECIMAL(18,2)
DECLARE @SP_CustAmt DECIMAL(18,2)

DECLARE @SP_Clrngdoc1 varchar(510)
DECLARE @SP_ExcVATAmt1 DECIMAL(18,2)
DECLARE @SP_VATAmt1 DECIMAL(18,2)
DECLARE @SP_TAXAmt1 DECIMAL(18,2)
DECLARE @SP_Withholdingtaxamnt1 DECIMAL(18,2)
DECLARE @SP_OtherTaxAmt1 DECIMAL(18,2)
DECLARE @SP_CustAmt1 DECIMAL(18,2)
DECLARE @SP_TotalChargeAmt1 DECIMAL(18,2)

DECLARE @TaxDesc varchar(255)
DECLARE @TaxRate float

DECLARE @DRunning INT
DECLARE @WHTRunning INT

DECLARE @C_DocumentNo	varchar(510)
DECLARE @C_Withhldtaxtype	varchar(510)
DECLARE @C_Wtaxbat	DECIMAL(18,2)
DECLARE @C_Withholdingtaxamnt	DECIMAL(18,2)
DECLARE @C_Wtaxrate	DECIMAL(18,2)
DECLARE @C_TaxDesc varchar(255)
DECLARE @C_TaxRate float
DECLARE @C_Loop	INT
DECLARE @LoopDetail INT
DECLARE @TotalAmountinLC	DECIMAL(18,2)
DECLARE @ShowCountWHTNo varchar(510)

DECLARE @iSupplyVendor	varchar(510)
DECLARE @iDispatchToCode	varchar(30)
DECLARE @iOtherReDoc	varchar(100)

DECLARE @RefDocument varchar(255)
DECLARE @WHTIncomeType varchar(20)

--DECLARE @OT_GL varchar(510)

DECLARE @CountLine INT
DECLARE @CountInvoice INT

DECLARE @CheckVendor AS INT

SET NOCOUNT ON

SET @CHQDATE='2024-10-30'  -- ##################  MUST INPUT FIRST --  วันที่จาก Mail--
SET @PrintData=''
SET @PrintData2=''
SET @CountLine=1
SET @CountWHTNo=0
SET @DRunning=1
SET @WHTRunning=0
SET @CountInvoice=0
SET @LoopDetail=0
SET @TotalAmountinLC=0

DELETE from [tbResultData]

SET @CheckVendor=0
SET @CheckVendor=	(Select COUNT(ISNULL(v1.Vendor,'')) From BSEG_Payment_Voucher pv
					INNER JOIN 
					(
						Select distinct documentno,vendor from BSEG_Payment_Voucher where NOT ISNULL(vendor,'')='' --IS NULL
					) v1 on v1.DocumentNO=pv.DocumentNo 
					Left JOIN Vendor v on v.vendorcode=ISNULL(v1.Vendor,'')
					where pv.GL like '10%' and v.vendorcode IS NULL ) 					

IF @CheckVendor=0 
BEGIN

	DECLARE Csr_Head CURSOR FOR 
	
	Select	pv.CoCd,Count(pv.DocumentNo),Sum(pv.AmountinLC)
	From BSEG_Payment_Voucher pv
	INNER JOIN 
	(
		Select distinct documentno,vendor
		from BSEG_Payment_Voucher
		where NOT ISNULL(vendor,'')='' --IS NULL
	) v1 on v1.DocumentNO=pv.DocumentNo 
	LEFT JOIN tbiSupplyVendor i ON i.VendorCode=v1.Vendor
	where pv.GL like '10%' AND i.VendorCode IS NULL
		--and pv.DocumentNo in ('1500004643','1500004644') -- Only for test
	Group by pv.CoCd

	OPEN Csr_Head

	FETCH NEXT FROM Csr_Head 
	INTO	@H_CoCd,@H_ChqCount,@H_Amount

	WHILE @@FETCH_STATUS = 0
	BEGIN

		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<?xml version="1.0" encoding="utf-8"?>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CstmrCdtTrfInitn>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<GrpHdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<MsgId>' + 'HTC_HSBC_File_'+@CHQDATE + '</MsgId>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CreDtTm>' + convert(varchar, getdate(), 126) + '</CreDtTm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Authstn><Cd>' + 'ILEV' + '</Cd></Authstn>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<NbOfTxs>' + Convert(varchar,@H_ChqCount) + '</NbOfTxs>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CtrlSum>' + Convert(varchar,@H_Amount) + '</CtrlSum>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<InitgPty>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Nm>' + 'HAIER ELECTRIC(THAILAND) PUBLIC COMPANY LIMITED' + '</Nm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Id><OrgId><Othr><Id>'+ 'ABC10385001'  + '</Id></Othr></OrgId></Id>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</InitgPty>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</GrpHdr>')

		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<PmtInf>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<PmtInfId>' + 'HTC_HSBC_File_'+@CHQDATE + '</PmtInfId>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<PmtMtd>' + 'CHK' + '</PmtMtd>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<NbOfTxs>' + Convert(varchar,@H_ChqCount) + '</NbOfTxs>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CtrlSum>' + Convert(varchar,@H_Amount) + '</CtrlSum>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<PmtTpInf>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<LclInstrm><Prtry>' + 'ICO' + '</Prtry></LclInstrm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CtgyPurp><Cd>' + 'SUPP' + '</Cd></CtgyPurp>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</PmtTpInf>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<ReqdExctnDt>' + @CHQDATE + '</ReqdExctnDt>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Dbtr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Nm>' + 'HAIER ELECTRIC(THAILAND) PUBLIC COMPANY LIMITED' + '</Nm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<PstlAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<StrtNm>' + '446 M.9, Kabinburi-Nakornratchasima Rd, T.Nongki, Kabinburi,' + '</StrtNm>')
		--SET @CountLine=@CountLine+1
		--Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<BldgNb>' + '' + '</BldgNb>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<PstCd>' + '25110' + '</PstCd>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<TwnNm>' + 'Prachinburi' + '</TwnNm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Ctry>' + 'TH' + '</Ctry>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</PstlAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</Dbtr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<DbtrAcct>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Id>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Othr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Id>' + '001XXXXXX001' + '</Id>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</Othr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</Id>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Ccy>' + 'THB' + '</Ccy>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Nm>' + 'HAIER ELECTRIC(THAILAND) PUBLIC COMPANY LIMITED' + '</Nm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</DbtrAcct>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<DbtrAgt>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<FinInstnId>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<BIC>' + 'HSBCTHBKXXX' + '</BIC>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<ClrSysMmbId><MmbId>' + '0310' + '</MmbId></ClrSysMmbId>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Nm>' + 'THE HONGKONG AND SHANGHAI BANKING CORPORATION LTD.' + '</Nm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<PstlAdr><Ctry>' + 'TH' + '</Ctry></PstlAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</FinInstnId>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</DbtrAgt>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<ChrgBr>' + 'DEBT' + '</ChrgBr>')
		
				
		FETCH NEXT FROM Csr_Head
		INTO	@H_CoCd,@H_ChqCount,@H_Amount
	END 
	CLOSE Csr_Head
	DEALLOCATE Csr_Head			
				
				

	DECLARE Csr_Wrk CURSOR FOR 
	
	Select	ISNULL(pv.Cl,''),ISNULL(pv.CoCd,''),ISNULL(pv.DocumentNo,''),ISNULL(pv.Year,''),ISNULL(pv.Itm,''),ISNULL(pv.Clearing,''),ISNULL(pv.ClgEntDate,''),ISNULL(pv.Clrngdoc,''),ISNULL(pv.PK,''),ISNULL(pv.DC,''),ISNULL(pv.WT,''),ISNULL(pv.AmountinLC,''),ISNULL(pv.Curr,''),ISNULL(pv.Withhldtaxbase,''),ISNULL(pv.GL,''),ISNULL(pv.Customer,''),ISNULL(v1.Vendor,''),ISNULL(i.VendorCode,'')
	From BSEG_Payment_Voucher pv
	INNER JOIN 
	(
		Select distinct documentno,vendor
		from BSEG_Payment_Voucher
		where NOT ISNULL(vendor,'')='' --IS NULL
	) v1 on v1.DocumentNO=pv.DocumentNo 
	LEFT JOIN tbiSupplyVendor i ON i.VendorCode=v1.Vendor
	where pv.GL like '10%' AND i.VendorCode IS NULL
		--and pv.DocumentNo in ('1500004643','1500004644') -- Only for test
	

	OPEN Csr_Wrk

	FETCH NEXT FROM Csr_Wrk 
	INTO	@Cl,@CoCd,@DocumentNo,@Year,@Itm,@Clearing,@ClgEntDate,@Clrngdoc,@PK,@DC,@WT,@AmountinLC,@Curr,@Withhldtaxbase,@GL,@Customer,@Vendor,@iSupplyVendor		

	WHILE @@FETCH_STATUS = 0
	BEGIN		
	
		IF @iSupplyVendor<>'' 
		BEGIN
			SET @iDispatchToCode='0029995'
			SET @iOtherReDoc='SPF'
		END
		ELSE
		BEGIN
			SET @iDispatchToCode='0020218'
			SET @iOtherReDoc='OR,OT'
		END
	
		
		SET @RefDocument=(select ISNULL(RefDocument,'') from tbPaymentDocument where documentno=@DocumentNo)
		IF @RefDocument IS NULL
		BEGIN
			SET @RefDocument=''
		END
		ELSE			
		BEGIN
			SET @RefDocument=@RefDocument
		END
	
		SET @LoopDetail=@LoopDetail+1		

		--################################################# Get Vendor Detail
		DECLARE Csr_Vendor CURSOR FOR 

		Select	ISNULL(v.[Tax ID],''),ISNULL(v.VendorCode,'') ,ISNULL(v.Name,''),ISNULL(v.Address,''),ISNULL(v.Fax,''),ISNULL(v.Tel,''),ISNULL(v.PND,''),ISNULL(v.VATRegisNo,''),ISNULL(v.TaxIDVendor3,'')
		From Vendor v 
		where v.VendorCode=@Vendor

		OPEN Csr_Vendor

		FETCH NEXT FROM Csr_Vendor 
		INTO	@V_TaxID,@V_VendorCode,@V_Name,@V_Address,@V_Fax,@V_Tel,@V_PND,@V_VATRegisNo,@V_TaxIDVendor3

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SET @TaxID=@V_TaxID
			SET @VendorCode=@V_VendorCode
			SET @Name=@V_Name
			SET @Address=@V_Address
			SET @Fax=@V_Fax
			SET @Tel=@V_Tel			
			IF (@V_PND <> '04') AND (@V_PND <> '07')
			BEGIN
				SET @PND=REPLACE(REPLACE(@V_PND,'07','07'),'05','04')
			END
			ELSE
			BEGIN				
				SET @PND=REPLACE(REPLACE(@V_PND,'07','7'),'04','4')
			END

			IF (@PND='04')
			BEGIN
				SET @PND='03'
			END
			ELSE				
			BEGIN
				SET @PND='53'
			END
			
			
			SET @VATRegisNo=@V_VATRegisNo

			SET @TaxIDVendor3=@V_TaxIDVendor3
			
		FETCH NEXT FROM Csr_Vendor
		INTO	@V_TaxID,@V_VendorCode,@V_Name,@V_Address,@V_Fax,@V_Tel,@V_PND,@V_VATRegisNo,@V_TaxIDVendor3
		END 
		CLOSE Csr_Vendor
		DEALLOCATE Csr_Vendor
		
		
		--################################################# Get Summary Invoice amount,Charge Amount, VAT amount, WHT amount
		SET @SP_Clrngdoc1=0
		SET @SP_ExcVATAmt1=0
		SET @SP_VATAmt1=0
		SET @SP_TAXAmt1=0
		SET @SP_Withholdingtaxamnt1=0
		SET @SP_OtherTaxAmt1=0
		SET @SP_CustAmt1=0
		SET @SP_TotalChargeAmt1=0
		
		DECLARE Csr_SumPay CURSOR FOR 

		Select	bp.Clrngdoc,
				ExcVATAmt=SUM(ISNULL(CASE WHEN bp.DC='S' THEN CASE WHEN v.VATAmt is null THEN i.InvoiceAmt*-1 ELSE (i.InvoiceAmt-v.VATAmt)*-1 END ELSE CASE WHEN v.VATAmt is null THEN i.InvoiceAmt ELSE (i.InvoiceAmt-v.VATAmt) END END,'')),		
				VATAmt=SUM(ISNULL(CASE WHEN bp.DC='S' THEN ISNULL(v.VATAmt,0)*-1 ELSE ISNULL(v.VATAmt,0) END,'')),
				TAXAmt=SUM(ISNULL(CASE WHEN bp.DC='S' THEN ISNULL(bp.Withholdingtax,0)*-1 ELSE ISNULL(bp.Withholdingtax,0) END,'')),
				Withholdingtaxamnt=ISNULL(t.Withholdingtaxamnt,0),
				OtherTaxAmt=ISNULL(otax.Amount,0),
				CustAmt=ISNULL(cus.Amount,0)
		from BSAK_Payment_Voucher bp
		LEFT JOIN vwBSEG_VAT v ON v.DocYear=bp.DocYear
		LEFT JOIN vwBSEG_Invoice i on i.DocYear=bp.DocYear 
		LEFT JOIN
		(
			select	DocumentNo,SUM(Withholdingtaxamnt) AS Withholdingtaxamnt
			from dbo.WHT_Amt 	
			Group by DocumentNo
		) t on t.DocumentNo=bp.Clrngdoc
		LEFT JOIN
		(
			Select	DocumentNo,
					Amount=SUM(CASE WHEN DC='H' THEN ISNULL(AmountinLC,0)*-1 ELSE ISNULL(AmountinLC,0) END)
			From BSEG_Payment_Voucher
			where	(						
						(GL like '2221020%' and ISNULL(WT,'')='' and ISNULL(Customer,'')='' and ISNULL(Vendor,'')='')
						OR
						(GL like '12210%' and ISNULL(WT,'')='' and ISNULL(Customer,'')='' and ISNULL(Vendor,'')='')
						OR 
						(GL like '60511%' and ISNULL(WT,'')='' and ISNULL(Customer,'')='' and ISNULL(Vendor,'')='')
					)	
			Group by DocumentNo
		) otax on otax.DocumentNo=bp.Clrngdoc
		LEFT JOIN 
		(
			Select	DocumentNo,
					Amount=SUM(ISNULL(AmountinLC,0)*-1)
			From BSEG_Payment_Voucher
			where	NOT ISNULL(Customer,'')='' --IS NULL
			Group by DocumentNo
		) cus on cus.DocumentNo=bp.Clrngdoc
		Where	bp.DocType<>'KZ' 
				and bp.Clrngdoc=@DocumentNo
		Group by bp.Clrngdoc,t.Withholdingtaxamnt,otax.Amount,cus.Amount

		OPEN Csr_SumPay

		FETCH NEXT FROM Csr_SumPay 
		INTO	@SP_Clrngdoc,@SP_ExcVATAmt,@SP_VATAmt,@SP_TAXAmt,@SP_Withholdingtaxamnt,@SP_OtherTaxAmt,@SP_CustAmt

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SET @SP_Clrngdoc1=@SP_Clrngdoc
			SET @SP_ExcVATAmt1=@SP_ExcVATAmt
			SET @SP_VATAmt1=@SP_VATAmt
			SET @SP_TAXAmt1=@SP_TAXAmt
			SET @SP_Withholdingtaxamnt1=@SP_Withholdingtaxamnt
			SET @SP_OtherTaxAmt1=@SP_OtherTaxAmt
			SET @SP_CustAmt1=@SP_CustAmt
			SET @SP_TotalChargeAmt1=@SP_OtherTaxAmt+@SP_CustAmt
			
		FETCH NEXT FROM Csr_SumPay
		INTO	@SP_Clrngdoc,@SP_ExcVATAmt,@SP_VATAmt,@SP_TAXAmt,@SP_Withholdingtaxamnt,@SP_OtherTaxAmt,@SP_CustAmt
		END 
		CLOSE Csr_SumPay
		DEALLOCATE Csr_SumPay
		
		
		--################################################# Get Detail Tax
		SET @D_TaxCount=ISNULL((Select Count(DocumentNo) from WHT_Amt where Withholdingtaxamnt>0 and DocumentNo=@DocumentNo group by DocumentNo),0)
		IF @D_TaxCount<>0 
		BEGIN
			SET @CountWHTNo=@CountWHTNo+1		
			SET @BeneRef=substring(@CHQDATE,5,4)+substring(@CHQDATE,3,2)+Substring(CAST(@CountWHTNo+1000000 as nchar(10)),2,6)+space(4)
			SET @ShowCountWHTNo=RTRIM(CAST(@CountWHTNo as Varchar(510)))
		END
		ELSE
		BEGIN
			SET @BeneRef=@V_VendorCode
			SET @ShowCountWHTNo=''
		END
			
		
						
		----################################################# End Get Tax by DocumentNo
		SET @CountInvoice=ISNULL((
			Select count(bp.DocumentNo) 
			from BSAK_Payment_Voucher bp 
			LEFT JOIN vwBSEG_VAT v ON v.DocYear=bp.DocYear
			LEFT JOIN vwBSEG_Invoice i on i.DocYear=bp.DocYear 
			Where bp.DocType<>'KZ' and bp.Clrngdoc=@DocumentNo
			),0)
					
		SET @TotalAmountinLC=@TotalAmountinLC+@AmountinLC

		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CdtTrfTxInf>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<PmtId>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<InstrId>' + @DocumentNo + '</InstrId>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<EndToEndId>' + @DocumentNo + '</EndToEndId>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</PmtId>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Amt><InstdAmt Ccy="THB">' + Convert(varchar,@AmountinLC) + '</InstdAmt></Amt>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<ChqInstr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<ChqTp>' + 'BCHQ' + '</ChqTp>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<DlvryMtd><Cd>' + 'PUCD' + '</Cd></DlvryMtd>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<DlvrTo>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Nm>' + 'HSBC' + '</Nm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Adr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<StrtNm>' + 'CHEQUE EXPRESS' + '</StrtNm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CtrySubDvsn>' + 'BANGKOK' + '</CtrySubDvsn>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Ctry>' + 'TH' + '</Ctry>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</Adr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</DlvrTo>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<MemoFld>' + 'TH_GCN004804225' + '</MemoFld>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</ChqInstr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CdtrAgt>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<FinInstnId>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<PstlAdr><Ctry>' + 'TH' + '</Ctry></PstlAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</FinInstnId>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</CdtrAgt>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Cdtr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Nm>' + @Name + '</Nm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<PstlAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<StrtNm>' + LEFT(SUBSTRING(LTRIM(RTRIM(@Address)),1,LEN(RTRIM(@Address))-5),70) + '</StrtNm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<PstCd>' + RIGHT(RTRIM(@Address),5) + '</PstCd>')

		IF (SUBSTRING(SUBSTRING(LTRIM(RTRIM(@Address)),1,LEN(RTRIM(@Address))-5),71,35))=''
		BEGIN
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<TwnNm>' + '-' + '</TwnNm>')
		END
		ELSE
		BEGIN
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<TwnNm>' + SUBSTRING(SUBSTRING(LTRIM(RTRIM(@Address)),1,LEN(RTRIM(@Address))-5),71,35) + '</TwnNm>')
		END
		
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Ctry>' + 'TH' + '</Ctry>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</PstlAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</Cdtr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RgltryRptg><Dtls><Inf>' + 'GOODS OR SERVICES' + '</Inf></Dtls></RgltryRptg>')		


	--	Insert into tbResultData(DocumentNo,IDData,ResultData) values(@DocumentNo,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),			
	--			RTRIM('003')+ '~' + --1
	--			RTRIM('HTC')+ '~' + --2
	--			RTRIM(@DRunning)+ '~' + --3		
	--			RTRIM('DMD15')+ '~' + --4
	--			RTRIM('')+ '~' + --5
	--			RTRIM(@CHQDATE)+ '~' + --6
	--			RTRIM('')+ '~' + --7
	--			RTRIM('THB')+ '~' + --8
	--			RTRIM(@DocumentNo)+ '~' + --9
	--			RTRIM(@CHQDATE)+ '~' + --10
	--			--RTRIM('R')+ '~' + --11
	--			RTRIM('O')+ '~' + --11
	--			RTRIM('BN')+ '~' + --12
	--			RTRIM('')+ '~' + --13
	--			RTRIM('U')+ '~' + --14
	--			RTRIM('M')+ '~' + --15
	--			RTRIM('M')+ '~' + --16
	--			RTRIM('M')+ '~' + --17
	--			RTRIM('M')+ '~' + --18
	--			RTRIM('Y')+ '~' + --19
	--			RTRIM('')+ '~' + --20
	--			RTRIM('0020218')+ '~' + --21
	--			--RTRIM('0020722')+ '~' + --21
	--			--RTRIM(@iDispatchToCode)+ '~' + --21
	--			RTRIM(RIGHT(@PND,1))+ '~' + --22
	--			RTRIM(@BeneRef)+ '~' + --23
	--			RTRIM('PVBC')+ '~' + --24
	--			RTRIM(@ShowCountWHTNo)+ '~' + --25
	--			RTRIM('')+ '~' + --26
	--			RTRIM('')+ '~' + --27
	--			RTRIM(@D_TaxCount)+ '~' + --28
	--			RTRIM(REPLACE(@SP_Withholdingtaxamnt1,'.',''))+ '~' + --29
	--			RTRIM(@CountInvoice)+ '~' + --30
	--			RTRIM(REPLACE((@SP_ExcVATAmt1+@SP_VATAmt1),'.',''))+ '~' + --31
	--			RTRIM('')+ '~' + --32
	--			RTRIM('OUR')+ '~' + --33
	--			RTRIM(REPLACE(@AmountinLC,'.',''))+ '~' + --34
	--			RTRIM('3')+ '~' + --35
	--			RTRIM('')+ '~' + --36
	--			RTRIM(@CHQDATE)+ '~' + --37
	--			RTRIM('002')+ '~' + --38
	--			RTRIM('0000')+ '~' + --39
	--			RTRIM('B')+ '~' + --40
	--			RTRIM('')+ '~' + --41
	--			RTRIM('')+ '~' + --42
	--			RTRIM('')+ '~' + --43
	--			RTRIM(@Name)+ '~' + --44
	--			RTRIM(SUBSTRING(@Address,1,50))+ '~' + --45
	--			RTRIM(SUBSTRING(@Address,51,50))+ '~' + --46
	--			RTRIM(SUBSTRING(@Address,101,50))+ '~' + --47
	--			RTRIM(SUBSTRING(@Address,151,50))+ '~' + --48
	--			RTRIM('')+ '~' + --49
	--			RTRIM('')+ '~' + --50
	--			RTRIM('')+ '~' + --51
	--			RTRIM('')+ '~' + --52
	--			--RTRIM('')+ '~' + --53
	--			RTRIM(@TaxID)+ '~' + --53				
	--			RTRIM('')+ '~' + --54
	--			RTRIM('')+ '~' + --55
	--			RTRIM('')+ '~' + --56
	--			RTRIM('')+ '~' + --57
	--			RTRIM('')+ '~' + --58
	--			--RTRIM('')+ '~' + --59
	--			RTRIM('OTH')+ '~' + --59
	--			--RTRIM('OR,OT,DRV')+ '~' + --60
	--			--RTRIM('')+ '~' + --60
	--			RTRIM(@RefDocument)+ '~' + --60
	--			RTRIM('')+ '~' + --61
	--			RTRIM('')+ '~' + --62
	--			RTRIM('')+ '~' + --63
	--			RTRIM('')+ '~' + --64
	--			RTRIM('') --65			
	--			)
				
	--			SET @DRunning=@DRunning+1
				
				
		--################################################# Get Tax Detail for print in INV Line
		SET @TaxSeq=10
		DECLARE Csr_Tax_D CURSOR FOR 

		select	ISNULL(w.DocumentNo,''),ISNULL(w.Withhldtaxtype,''),ISNULL(w.Wtaxrate,''),SUM(w.Wtaxbat) as Wtaxbat,SUM(w.Withholdingtaxamnt) AS Withholdingtaxamnt,ISNULL(t.TaxDesc,''),TaxRate=ISNULL(t.TaxRate,0)
				from dbo.WHT_Amt w
				LEFT JOIN tbTaxType t ON t.TaxType=w.Withhldtaxtype
				where w.DocumentNo=@DocumentNo
				Group by w.DocumentNo,w.Withhldtaxtype,w.Wtaxrate,t.TaxDesc,t.TaxRate
				having SUM(w.Withholdingtaxamnt)<>0

		OPEN Csr_Tax_D

		FETCH NEXT FROM Csr_Tax_D 
		INTO	@T_DocumentNo,@T_Withhldtaxtype,@T_Wtaxrate,@T_Wtaxbat,@T_Withholdingtaxamnt,@TaxDesc,@TaxRate

		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Tax>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Cdtr><TaxId>' + @TaxID + '</TaxId></Cdtr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Dbtr><TaxId>' + '0107536001320' + '</TaxId></Dbtr>')		
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Mtd>' + '3' + '</Mtd>') --?????????????????????????

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SET @WHTIncomeType=(
								CASE RTRIM(@T_Withhldtaxtype) 
								WHEN 'RN' THEN 'RENT'
								WHEN 'SV' THEN 'SERVICE'
								WHEN 'TP' THEN 'TRANSPORTATION'
								WHEN 'AD' THEN 'ADVERTISMENT'
								WHEN 'IP' THEN 'INSURANCE'
								WHEN 'FC' THEN 'FREIGHT CHARGE'
								WHEN 'TW' THEN 'HIRE OF WORK'
								ELSE 'XX' END
								)
				
			
			SET @TaxSeq=@TaxSeq+1							
			
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Rcrd>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Tp>' + '/WHT0'+Convert(varchar,@TaxSeq)+'/' + '</Tp>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Ctgy>' + Convert(varchar,@TaxSeq+40) + '</Ctgy>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CtgyDtls>' + '{'+ RTRIM(REPLACE(@T_Withholdingtaxamnt,'.','')) +'} '+ @WHTIncomeType + ' ' + Convert(varchar,@TaxRate) + ' %' + '</CtgyDtls>')
			--SET @CountLine=@CountLine+1
			--Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CertId>' + '' + '</CertId>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<FrmsCd>' + @PND + '</FrmsCd>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<TaxAmt>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Rate>' +  CAST(CAST(@TaxRate as decimal(3,2)) as varchar(4)) + '</Rate>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<TaxblBaseAmt Ccy="THB">' + Convert(varchar,@T_Wtaxbat) + '</TaxblBaseAmt>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</TaxAmt>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</Rcrd>')


			--Insert into tbResultData(DocumentNo,IDData,ResultData) values(@DocumentNo,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),
			--		RTRIM('005')+ '~' + --1
			--		RTRIM(@DocumentNo)+ '~' + --2
			--		RTRIM(@TaxSeq)+ '~' + --3
			--		RTRIM(REPLACE(@T_Withholdingtaxamnt,'.',''))+ '~' + --4
			--		--RTRIM('05')+ '~' + --5
			--		RTRIM(@WHTIncomeType)+ '~' + --5					
			--		--RTRIM(RIGHT('0000'+ CAST(CAST(@TaxRate as decimal(3,2)) as varchar(4)),4))+ '~' + --6
			--		RTRIM(RIGHT('0000'+ REPLACE(CAST(CAST(@TaxRate as decimal(3,2)) as varchar(4)),'.',''),4))+ '~' + --6
			--		RTRIM(REPLACE(@T_Wtaxbat,'.','')) --7							
					
			--		)	
						
		FETCH NEXT FROM Csr_Tax_D
		INTO	@T_DocumentNo,@T_Withhldtaxtype,@T_Wtaxrate,@T_Wtaxbat,@T_Withholdingtaxamnt,@TaxDesc,@TaxRate
		END 
		CLOSE Csr_Tax_D
		DEALLOCATE Csr_Tax_D		
		
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</Tax>')

		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RltdRmtInf>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RmtLctnMtd>' + 'EMAL' + '</RmtLctnMtd>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RmtLctnElctrncAdr>' + @TaxIDVendor3 + '</RmtLctnElctrncAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RmtLctnPstlAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Nm>' + @Name + '</Nm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Adr><Ctry>' + 'TH' + '</Ctry></Adr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</RmtLctnPstlAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</RltdRmtInf>')

		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RltdRmtInf>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RmtLctnMtd>' + 'EMAL' + '</RmtLctnMtd>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RmtLctnElctrncAdr>' + 'chotika.a@haier.co.th' + '</RmtLctnElctrncAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RmtLctnPstlAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Nm>' + 'Chotika Aomsap' + '</Nm>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Adr><Ctry>' + 'TH' + '</Ctry></Adr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</RmtLctnPstlAdr>')
		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</RltdRmtInf>')
				
		--################################################# Get Invoice Detail
		
		SET @LoopINV=0
		SET @SI_ExcVATAmt=0
		SET @SI_VATAmt=0
		SET @SI_TAXAmt=0
		DECLARE Csr_Invoice CURSOR FOR 

		Select	ISNULL(bp.Reference,''),ISNULL(bp.DocumentNo,''),ISNULL(bp.DocDate,''),ISNULL(bp.DocYear,''),
				--ExcVATAmt=ISNULL(CASE WHEN bp.DC='S' THEN CASE WHEN v.VATAmt is null THEN i.InvoiceAmt*-1 ELSE (i.InvoiceAmt-v.VATAmt)*-1 END ELSE CASE WHEN v.VATAmt is null THEN i.InvoiceAmt ELSE (i.InvoiceAmt-v.VATAmt) END END,''),		
				ExcVATAmt=ISNULL(CASE WHEN bp.DC='S' THEN ISNULL(bp.Discountbase,0)*-1 ELSE ISNULL(bp.Discountbase,0) END,''),		
				--VATAmt=ISNULL(CASE WHEN bp.DC='S' THEN ISNULL(v.VATAmt,0)*-1 ELSE ISNULL(v.VATAmt,0) END,''),
				VATAmt=ISNULL(CASE WHEN bp.DC='S' THEN (ISNULL(bp.AmountinLC,0)*-1)-(ISNULL(bp.Discountbase,0)*-1) ELSE ISNULL(bp.AmountinLC,0)-ISNULL(bp.Discountbase,0) END,''),
				TAXAmt=ISNULL(CASE WHEN bp.DC='S' THEN ISNULL(bp.Withholdingtax,0)*-1 ELSE ISNULL(bp.Withholdingtax,0) END,''),
				ShowInvoice='INV|'+ substring(ISNULL(bp.Reference,'') + space(21),1,21) +'|'+ substring(ISNULL(bp.DocYear,'') + space(20),1,20) +'|'+ substring(ISNULL(bp.DocDate,'') + space(10),1,10) +'|'+ 
							substring(CAST(ISNULL(CASE WHEN bp.DC='S' THEN CASE WHEN v.VATAmt is null THEN i.InvoiceAmt*-1 ELSE (i.InvoiceAmt-v.VATAmt)*-1 END ELSE CASE WHEN v.VATAmt is null THEN i.InvoiceAmt ELSE (i.InvoiceAmt-v.VATAmt) END END,'') as varchar(510)) + space(16),1,16) +'|'+ 
							substring(CAST(ISNULL(CASE WHEN bp.DC='S' THEN ISNULL(v.VATAmt,0)*-1 ELSE ISNULL(v.VATAmt,0) END,'') as varchar(510)) + space(16),1,16) +'|'+ 
							substring(CAST(ISNULL(CASE WHEN bp.DC='S' THEN ISNULL(bp.Withholdingtax,0)*-1 ELSE ISNULL(bp.Withholdingtax,0) END,'') as varchar(510)) + space(16),1,16)+ '|' ,
				INVType=ISNULL(CASE WHEN bp.DC='S' THEN 'C/N' ELSE 'INV' END,''),
				INVSign=ISNULL(CASE WHEN bp.DC='S' THEN '-' ELSE '0' END,'0')
		from BSAK_Payment_Voucher bp
		LEFT JOIN vwBSEG_VAT v ON v.DocYear=bp.DocYear
		LEFT JOIN vwBSEG_Invoice i on i.DocYear=bp.DocYear 
		Where bp.DocType<>'KZ' and bp.Clrngdoc=@DocumentNo	

		OPEN Csr_Invoice

		FETCH NEXT FROM Csr_Invoice 
		INTO	@I_Reference,@I_DocumentNo,@I_DocDate,@I_DocYear,@I_ExcVATAmt,@I_VATAmt,@I_TAXAmt,@I_ShowInvoice,@INVType,@INVSign

		SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RmtInf>')

		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			SET @SI_ExcVATAmt=@SI_ExcVATAmt+@I_ExcVATAmt
			SET @SI_VATAmt=@SI_VATAmt+@I_VATAmt
			SET @SI_TAXAmt=@SI_TAXAmt+@I_TAXAmt
			
			SET @CountLine=@CountLine+1
			SET @LoopINV=@LoopINV+1
			
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Strd>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RfrdDocInf>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Nb>' + @I_Reference + '</Nb>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RltdDt>' + REPLACE(@I_DocDate,'.','-') + '</RltdDt>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</RfrdDocInf>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<RfrdDocAmt><DuePyblAmt Ccy="THB">' + Convert(varchar,@I_ExcVATAmt+@I_VATAmt) + '</DuePyblAmt></RfrdDocAmt>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CdtrRefInf>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Tp>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<CdOrPrtry><Prtry>' + '/AMNT/'+ Convert(varchar,@I_VATAmt) + '</Prtry></CdOrPrtry>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</Tp>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<Ref>' + '/NARR/' + Convert(varchar,@I_ExcVATAmt) + '</Ref>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</CdtrRefInf>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'<AddtlRmtInf>' + @I_DocumentNo + '</AddtlRmtInf>')
			SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</Strd>')			

			--Insert into tbResultData(DocumentNo,IDData,ResultData) values(@DocumentNo,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),
			--		RTRIM('006')+ '~' + --1
			--		RTRIM(@I_Reference+'_'+@V_VendorCode+'_'+substring(@I_DocDate ,9,2)+substring(@I_DocDate ,6,2)+substring(@I_DocDate ,1,4))+ '~' + --2
			--		RTRIM(REPLACE((@I_ExcVATAmt+@I_VATAmt),'.',''))+ '~' + --3
			--		RTRIM('')+ '~' + --4
			--		RTRIM(REPLACE(@I_VATAmt,'.',''))+ '~' + --5
			--		RTRIM(@DocumentNo)--6		
			--		)								
						
		FETCH NEXT FROM Csr_Invoice
		INTO	@I_Reference,@I_DocumentNo,@I_DocDate,@I_DocYear,@I_ExcVATAmt,@I_VATAmt,@I_TAXAmt,@I_ShowInvoice,@INVType,@INVSign
		END 
		CLOSE Csr_Invoice
		DEALLOCATE Csr_Invoice			

		SET @CountLine=@CountLine+1
			Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</RmtInf>')

		SET @CountLine=@CountLine+1
		Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</CdtTrfTxInf>')

		FETCH NEXT FROM Csr_Wrk
		INTO	@Cl,@CoCd,@DocumentNo,@Year,@Itm,@Clearing,@ClgEntDate,@Clrngdoc,@PK,@DC,@WT,@AmountinLC,@Curr,@Withhldtaxbase,@GL,@Customer,@Vendor,@iSupplyVendor
	END 
	CLOSE Csr_Wrk
	DEALLOCATE Csr_Wrk

	--IF @LoopDetail<>0 
	--BEGIN
	--	SET @CountLine=@CountLine+1		
	--	Insert into tbResultData(DocumentNo,IDData,ResultData) values(@DocumentNo,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),				
	--			RTRIM('100')+ '~' + --1
	--			RTRIM(@LoopDetail)+ '~' + --2
	--			RTRIM(REPLACE(@TotalAmountinLC,'.','')) --3			
	--			)	
	--END
	SET @CountLine=@CountLine+1
	Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</PmtInf>')
	SET @CountLine=@CountLine+1
	Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</CstmrCdtTrfInitn>')
	SET @CountLine=@CountLine+1
	Insert into tbResultData(DocumentNo,IDData,ResultData) values(@H_CoCd,Substring(CAST(@CountLine+100000 as nchar(10)),2,5),'</Document>')
END
ELSE
BEGIN
	PRINT 'Please check vendor master data'
END

