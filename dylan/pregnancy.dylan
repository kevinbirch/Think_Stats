module: pregnancy
synopsis: prints the total number of pregnancies
author: kevin birch <kevin.birch@gmail.com>

define class <pregnancy> (<object>)
  slot case-id :: <integer>;
  // xxx - how can we have an enumeration?
  slot sex :: <integer>;
  slot pregnancy-weeks :: <integer>;
  slot live-birth?;
  slot birth-ordinal :: <integer>;
  slot statistical-weight;
end class;

define method print-message(value :: <pregnancy>, stream :: <stream>) => ()
  format(stream, "{case-id: %s, duration: %s}", value.case-id, value.pregnancy-weeks);
end;

define function number-of-pregnancies(file-name :: <pathname>)

  let records = list();
  with-open-file(file-stream = file-name)
    while (~stream-at-end?(file-stream))
      records := parse-record(read-line(file-stream), records);
    end;
  end;

  format-out("I'm pregnant!\n");
  format-out("loaded %d records\n", size(records));
  do (method (a) format-out("{case-id: %s, duration: %s}\n", a.case-id, a.pregnancy-weeks) end, records);
end function number-of-pregnancies;

define function parse-record(line :: <string>, records :: <list>)
  => records :: <list>;

  let record = make(<pregnancy>);
  // xxx - how can we make a macro to do the stoi and subseq stuff?
  record.case-id := string-to-integer(copy-sequence(line, start: 0, end: 12));
  // awk the file to see if there are nulls for this field...
  //record.sex := string-to-integer(copy-sequence(line, start: 55, end: 56));
  record.pregnancy-weeks := string-to-integer(copy-sequence(line, start: 274, end: 276));

  add!(records, record);
end function parse-record;

// Invoke our main() function.
number-of-pregnancies(first(application-arguments()));
