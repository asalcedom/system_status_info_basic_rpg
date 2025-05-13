**free
ctl-opt option(*nodebugio:*srcstmt:*nounref);

dcl-f db2sysstsi workstn indds(indicators);

///copy qsysinc/qrpglesrc,qwcrssts
//
//dcl-pr QWCRSSTS extpgm;
//  stsInfo        likeds(QWCS0200) options(*varsize); //Fixed fields
//  stsInfoLen     int(10)   const;
//  stsInfoFmt     char(8)   const;
//  stsResetStats  char(26)  const;
//  stsErrCode     likeds(apiErrC) options(*varsize);
//end-pr;
//
//dcl-ds apiErrC qualified Inz;
//  bytesProv  int(10:0) Inz(%size(apiErrC));
//  bytesAvail int(10:0);
//  msgId      char(7);
//  *n         char(1);
//  msgData    char(3000);
//end-ds;

dcl-ds indicators;
  exit ind pos(3);
end-ds;

dcl-ds sysStsDs qualified; // Only the fields needed
  elap_used         packed(5:2);
  elap_time_seconds int(10);
  total_jobs        int(10);
  perm_rate         packed(6:3);
  temp_rate         packed(6:3);
  sys_stg           int(20);
  sys_rate          packed(5:2);
  aux_stg           int(20);
  temp_curr         int(10);
  temp_max          int(10);
end-ds;

dcl-s hours   char(2);
dcl-s minutes char(2);
dcl-s seconds char(2);

pgmname = 'DB2SYSSTSI';
write header;
write fkeys;

dow not exit;
  exec sql
    select elapsed_cpu_used, elapsed_time, total_jobs_in_system, permanent_address_rate,
           temporary_address_rate, system_asp_storage, system_asp_used, total_auxiliary_storage,
           current_temporary_storage, maximum_temporary_storage_used
      into :sysStsDs
      from qsys2.system_status_info_basic;

  // elap_time
  hours   = %editc(%dec(%div(sysStsDs.elap_time_seconds:3600):2:0):'X');
  minutes = %editc(%dec(%div(%rem(sysStsDs.elap_time_seconds:3600):60):2:0):'X');
  seconds = %editc(%dec(%rem(%rem(sysStsDs.elap_time_seconds:3600):60):2:0):'X');

  elap_used  = sysStsDs.elap_used;
  elap_time  = hours + ':' + minutes + ':' + seconds;
  total_jobs = sysStsDs.total_jobs;
  perm_rate  = sysStsDs.perm_rate;
  temp_rate  = sysStsDs.temp_rate;
  sys_stg    = sysStsDs.sys_stg / 1000;
  sys_rate   = sysStsDs.sys_rate;
  aux_stg    = sysStsDs.aux_stg / 1000;
  temp_curr  = sysStsDs.temp_curr;
  temp_max   = sysStsDs.temp_max;

  exfmt sysstsdta;
enddo;

*inlr = *on; 
