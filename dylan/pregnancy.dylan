module: pregnancy
synopsis: deals with the pregnancy survey cohort data set
author: kevin birch <kevin.birch@gmail.com>

define constant $male = #"male";
define constant $female = #"female";

define constant <gender> = type-union(singleton($male), singleton($female));

define constant <outcome> = type-union(singleton(#"live-birth"), singleton(#"abortion"), singleton(#"still-birth"), singleton(#"miscarraige"), singleton(#"ectopic"), singleton(#"current"));

define class <pregnancy> (<object>)
  slot case-id :: <integer>, required-init-keyword: case-id:;
  slot gender :: false-or(<gender>) = #f;
  slot weeks :: <integer>;
  slot outcome :: <outcome>;
  virtual slot live-birth? :: <boolean>;
  //slot birth-ordinal :: <integer>;
  //slot statistical-weighting;
end class;

define method live-birth?(value :: <pregnancy>) => result :: <boolean>;
  value.outcome = #"live-birth";
end;

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
      1 => $male;
      2 => $female;
      otherwise => #f;
    end;

  // xxx - how can we make a macro to do the stoi and subseq stuff?
  record.weeks := string-to-integer(copy-sequence(line, start: 274, end: 276));
  record.outcome := 
    select(string-to-integer(copy-sequence(line, start: 276, end: 277)))
      1 => #"live-birth";
      2 => #"abortion";
      3 => #"still-birth";
      4 => #"miscarraige";
      5 => #"ectopic";
      6 => #"current";
    end;
  record;
end;

define method number-of-pregnancies(records :: <list>)
  format-out("loaded %d records\n", size(records));
end;

define method number-missing-gender(records :: <list>)
  format-out("%d records missing gender\n", size(choose(method(a) a.gender = #f end, records)));
end;

define method number-of-live-births(records :: <list>)
  format-out("%d live births\n", size(choose(method(a) a.live-birth? end, records)));
end;

define method main(application-name :: <string>, arguments :: <simple-object-vector>)
  let records = load-data-set(first(arguments));
  number-of-pregnancies(records);
  number-missing-gender(records);
  number-of-live-births(records);
end;

main(application-name(), application-arguments());
