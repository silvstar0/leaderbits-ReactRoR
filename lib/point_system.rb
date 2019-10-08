# frozen_string_literal: true

class PointSystem
  def initialize(user)
    @user = user
    @user_levels = []
  end

  # @return [PointSystem]
  def parse!
    File.read(__FILE__).split("__END__\n")[-1].lines.each do |line|
      level_num, from, _until = line.split("\t")

      @user_levels << OpenStruct.new(from: from.to_i, until: _until.to_i, num: level_num)
    end
    self
  end

  def current_level
    @user_levels.find { |ostruct| (ostruct.from..ostruct.until).cover? @user.total_points }
  end

  # @return [Integer]
  def current_level_num
    check_current_level_presense!

    current_level.num.to_i
  end

  # @return [Integer]
  def next_level_num
    @user_levels.find { |ostruct| ostruct.from > @user.total_points }.num.to_i
  end

  # @return [Integer]
  def max_points_for_current_level
    check_current_level_presense!

    current_level.until
  end

  def total_levels_count
    @user_levels.count
  end

  private

  def check_current_level_presense!
    raise "can not fetch current level for #{@user.inspect}" if current_level.nil?
  end
end

# Why plain text format? Because next time spreadsheet is updated, you'll copy and paste never version without need to touch any actual code.
__END__
1	0	230
2	231	460
3	461	690
4	691	920
5	921	1150
6	1151	1380
7	1381	1610
8	1611	1840
9	1841	2070
10	2071	2300
11	2301	2530
12	2531	2760
13	2761	2990
14	2991	3220
15	3221	3450
16	3451	3795
17	3796	4140
18	4141	4485
19	4486	4830
20	4831	5175
21	5176	5520
22	5521	5865
23	5866	6210
24	6211	6555
25	6556	6900
26	6901	7360
27	7361	7820
28	7821	8280
29	8281	8740
30	8741	9200
31	9201	9660
32	9661	10120
33	10121	10695
34	10696	11270
35	11271	11845
36	11846	12420
37	12421	12995
38	12996	13570
39	13571	14145
40	14146	1472
41	14721	15295
42	15296	15870
43	15871	16560
44	16561	17250
45	17251	17940
46	17941	18630
47	18631	19320
48	19321	20010
49	20011	20700
50	20701	21505
51	21506	22310
52	22311	23115
53	23116	23920
