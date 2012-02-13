module: pregnancy
synopsis: deals with the pregnancy survey cohort data set
author: kevin birch <kevin.birch@gmail.com>

define constant *male* = #"male";
define constant *female* = #"female";

define constant <gender> = type-union(singleton(*male*), singleton(*female*));

define class <pregnancy> (<object>)
  slot case-id :: <integer>, required-init-keyword: case-id:;
  slot gender :: false-or(<gender>) = #f;
  slot weeks :: <integer>;
  //slot live-birth?;
  //slot birth-ordinal :: <integer>;
  //slot statistical-weighting;
end class;

define method load-data-set(file-name :: <pathname>) => records :: <list>;
  let records = list();
  with-open-file(file-stream = file-name)
    while (~stream-at-end?(file-stream))
        records := add!(records, parse-record(read-line(file-stream)));
    end;
  end;
  
  records;
end;

define method parse-record(line :: <string>) => record :: <pregnancy>;
  let record = make(<pregnancy>, case-id: string-to-integer(copy-sequence(line, start: 0, end: 12)));

  record.gender := 
    select(string-to-integer(copy-sequence(line, start: 55, end: 56), default: 0))
      1 => *male*;
      2 => *female*;
      otherwise => #f;
    end;

  // xxx - how can we make a macro to do the stoi and subseq stuff?
  record.weeks := string-to-integer(copy-sequence(line, start: 274, end: 276));
  
  record;
end;

define method number-of-pregnancies(records :: <list>)
  format-out("loaded %d records\n", size(records));
end;

define method number-missing-gender(records :: <list>)
  format-out("%d records missing gender\n", size(choose(method(a) a.gender = #f end, records)));
end;

define method main(application-name :: <string>, arguments :: <simple-object-vector>)
  let records = load-data-set(first(arguments));
  number-of-pregnancies(records);
  number-missing-gender(records);
end;

main(application-name(), application-arguments());
