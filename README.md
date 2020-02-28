# hats-R
all Projects related with R
hats here ,
this is the edit version of the readme section.

# data transformation with dplyr using flights data set 
title: "Chapter 3: Data Transformation with dplyr"
output: github_document
---

```{r global_options, include=FALSE}
knitr::opts_chunk$set(fig.width=12, fig.height=8, fig.path='Figs/',
                      warning=FALSE, message=FALSE)
```

### 3.1 Introduction
#### 3.1.1 Prerequisites
```{r Load Libraries}
library(nycflights13)
library(tidyverse)
```

#### 3.1.2 nycflights13
The data set we'll be working with to learn data transformation:
```{r 3.1.2.1 nycflights13 Note}
nycflights13::flights
```

#### 3.1.3 `dplyr` Basics
**Five key `dplyr` functions:**
* Pick observations by their values `(filter())`.
* Reorder the rows `(arrange())`.
* Pick variables by their names `(select())`.
* Create new variables with functions of existing variables `(mutate())`.
* Collapse many values down to a single summary `(summarise())`.
* Control processing of the mentioned functions with `(group_by())`.

**All verbs work similarly:**
* First argument is a data frame.
* Subsequent arugments describe what to do with the data frame, using variable names (without quotes).
* The result is a new data frame.

`filter()`. Note: `dplyr` functions do not modify their inputs. So save the result (with `<-`) to a variable if that is your desired outcome. R will either print the result or save it to the assigned variable. To do both, wrap entirely in parentheses.

#### 3.1.4 Filter Rows with `filter()`
```{r 3.1.4.1 Filter Rows Note}
(jan1 <- filter(flights, month == 1, day == 1)) 
```

#### 3.1.5 Comparisons
To use filter effectively, you have to master the comparison operators: `>, >=, <, <=, != (not equal), and == (equal)`. A simple and common mistake is using `=` instead of `==`.Another is related to floating-point numbers, which basically means the R stores numbers as approximations. You will get surprising results like this:
```{r 3.1.5.1 Comparisons Note}
sqrt(2) ^ 2 == 2
```
```{r 3.1.5.2 Comparisons Note}
1 / 49 * 49 == 1
```

These are returning false because R cannot store the precise number! The floating-point conundrum is common in computer science. Address it in R with the following:
```{r 3.1.5.3 Comparisons Note}
near(sqrt(2) ^ 2, 2)
```
```{r 3.1.5.4 Comparisons Note}
near(1 / 49 * 49, 1)
```

#### 3.1.5 Logical Operators 
`%in` is a useful shortcut to compare among multiple values
```{r 3.1.5.5 Comparisons Note}
nov_dec <- filter(flights, month %in% c(11, 12))
```

#### 3.1.6 Missing Values
`filter()` only includes rows where the condition is `TRUE`; it excludes both `FALSE` and `NA` values. You have to explicitly ask for `NA` if you want to preserve them. 
```{r 3.1.6.1 Missing Values Note}
df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)
```

```{r 3.1.6.2 Missing Values Note}
filter(df, is.na(x) | x > 1)
```

#### 3.1.7 Exercises
1. Find all flights that:
a. Had an arrival delay of two or more hours
Here I used a couple functions I am already aware of, including `arrange()` and `%>%` (pipe). More on pipe later. Noticed I had to view the data first with `?` and `glimpse()` before constructing `filter()` functions.
```{r 3.1.7.1.1 Exercise}
data('flights')
glimpse(flights)
?flights
filter(flights, arr_delay >= 120) %>% 
  arrange(arr_delay)
```

b. Flew to Houston (IAH or HOU)
```{r 3.1.7.1.2 Exercise}
filter(flights, dest %in% c('IAH', 'HOU')) %>% 
  arrange(dest)
```

c. Were operated by United, American, or Delta
```{r 3.1.7.1.3 Exercise}
filter(flights, carrier %in% c('UA', 'AA', 'DL')) %>% 
  arrange(carrier)
```

d. Departed in summer (July, August, and September)
```{r 3.1.7.1.4 Exercise}
filter(flights, between(month, 7, 9)) %>% 
  arrange(month)
```

e. Arrived more than two hours late, but didn't leave late
```{r 3.1.7.1.5 Exercise}
filter(flights, arr_delay > 120, dep_delay <= 0) %>% 
  arrange(arr_delay, dep_delay)
```

f. Were delayed by at least an hour, but made up over 30 minutes in flight
```{r 3.1.7.1.6 Exercise}
filter(flights, dep_delay >= 60 & dep_delay - arr_delay > 30) %>% 
  arrange(dep_delay, arr_delay)
```

g. Departed between midnight and 6 a.m. (inclusive)
```{r 3.1.7.1.7 Exercise}
filter(flights, between(dep_time, 0, 600)) %>% 
  arrange(dep_time)
```

2. Another useful `dplyr` filtering helper is `between()`. What does it do? Can you use it to simplify the code needed to answer previous challenges? `between()` is a shortcut for `>=` and `<=` operands. This is achieved with the syntax: `between(x, left, right)`, with left and right corresponding to the range. The `between()` function is *inclusive*; meaning, it includes the left and right values in the comparison. I have already used `between()` in the previous question for applicable filters.

3. How many flights have a missing `dep_time`? What other variables are missing? What might these rows represent? `r nrow(filter(flights, is.na(dep_time)))`. Looks like cancelled flights. Every variable associated with measuring time of flight is missing. 
```{r 3.1.7.3 Exercise}
nrow(filter(flights, is.na(dep_time)))
```

4. Why is `NA ^ 0` not missing? Why is `NA | TRUE` not missing? Why is `FALSE & NA` not missing? Can you figure out the general rule? (`NA * 0` is a tricky counterexample!).
Anything raised to 0 is 1.
```{r 3.1.7.4.1 Exercise}
NA ^ 0
1 ^ 0
NaN ^ 0
FALSE ^ 0
```

The or operand `|` will evaluate to `TRUE` if it is apart of the comparison, regardless of the other comparison.
```{r 3.1.7.4.2 Exercise}
TRUE | NA
TRUE | FALSE
FALSE | TRUE
TRUE | -1
TRUE | NaN
```

`FALSE` combined with the `&` operand will always evaluate to `FALSE` if it is included in the comparison.
```{r 3.1.7.4.3 Exercise}
FALSE & NA
FALSE & TRUE
FALSE & NaN
FALSE & FALSE
```

The reason that `NA * 0` is not equal to 0 is that `x * 0 = NaN` is undefined when `x = Inf` or `x = -Inf.`
```{r 3.1.7.4.4 Exercise}
NA * 0
Inf * 0
-Inf * 0
```

### 3.2 Arrange Rows with `arrange()`
`arrange()` changes order of rows. If more than one column name is passed, it will use each additional column to break ties in values of the preceding columns.
```{r 3.2.1 Arrange Rows with `arrange()`}
arrange(flights, year, month, day)
```

`desc()` is used to reorder by a column in deascending order:
```{r 3.2.2 Arrange Rows with `arrange()`}
arrange(flights, desc(arr_delay))
```

Note: missing values are always sorted at the end
```{r 3.2.3 Arrange Rows with `arrange()`}
df <- tibble(x = c(5, 2, NA))
arrange(df, x)
arrange(df, desc(x))
arrange(df, !is.na(x))
```

#### 3.2.2 Exercises
1. How could you use `arrange()` to sort all missing values to the start? (Hint: use `is.na()`.) Both method below put `NA` values first. Why, you ask? Well `is.na()` returns a boolean of `TRUE` if the value is `NA` and `FALSE` if the value is not `NA`. `TRUE` and `FALSE` are evaluated as 1 and 0 in R, respectively. `arrange()` sorts in ascending order by default, so the `TRUE` value of `NA` gets pushed to the top of the list. We then add the same column again to resume the sort by actual values. 
```{r 3.2.2.1 Exercise}
arrange(flights, !is.na(arr_delay), arr_delay)
arrange(flights, desc(is.na(arr_delay)), arr_delay)
```

2. Sort `flights` to find the most delayed flights. Find the flights that left earliest. 
```{r 3.2.2.2 Exercise}
arrange(flights, desc(dep_delay))
arrange(flights, dep_delay)
```

3. Sort `flights` to find the fastest flights.
```{r 3.2.2.3 Exercise}
arrange(flights, air_time)
```

4. Which flights traveled the longest? Which traveled the shortest?
* Longest: HA, HNL
* Shortest: US flight was cancelled, so the shortesdt travel was EV, EWR
```{r 3.2.2.4 Exercise}
arrange(flights, desc(distance))
arrange(flights, distance)
```

### 3.3 Select columns with `select()`
Helper functions with `select()`
* `starts_with('abc')` matches names that begin with 'abc'.
* `ends_with('xyz')` matches names that end with 'xyz'.
* `contains('ijk')` matches names that contain 'ijk'.
* `matches('(.)\\1')` selects variables that match a regular expression. This one matches any variables that contain repeated characters. Regular express are touched on more in Chapter 11.
* `num_range('x', 1:3')` matches x1, x2, and x3.

Use `rename()`, instead of `select()` to rename columns. Using only the latter will select only the columns renamed.
```{r 3.3.1 Select columns with select() Note}
rename(flights, tail_num = tailnum)
```

`everything()` is another useful option with `select()`. It can be used to move variables to the start of a data frame.
```{r 3.3.2 Select columns with select() Note}
select(flights, time_hour, air_time, everything())
```

#### 3.3.1 Exercises
1. Brainstorm as many ways possible to select `dep_time`, `dep_delay`, `arr_time`, and `arr_delay` from `flights`.
```{r 3.3.1.1 Exercise}
select(flights, dep_time, dep_delay, arr_time, arr_delay)
select(flights, starts_with('dep'), starts_with('arr'))
select(flights, contains('delay'), dep_time, arr_time)
select(flights, matches("^(dep|arr)_(time|delay)$"))
```

2. What happens if you include the name of a variable multiple times in a `select()` call? The variable is only displayed once and the duplicate is ignored.
```{r 3.3.1.2 Exercise}
select(flights, dep_time, dep_time)
```

3. What does the `one_of()` function do? Why might it be helpful in conjunction with this vector? `vars <- c('year', 'month', 'day', 'dep_delay', 'arr_delay')`

`one_of()` allows you to search a defined character vector for matches with column names in a data frame.

```{r 3.3.1.3 Exercise}
vars <- c('year', 'month', 'day', 'dep_delay', 'arr_delay')
select(flights, one_of(vars))
```

4. Does the result of running the following code surprise you? How does the select helpers deal with case by default? How can you change that default? They are not case sensitive. Change default case.

```{r 3.3.1.4 Exercise}
select(flights, contains("TIME"))
select(flights, contains("TIME", ignore.case = FALSE))
```

### 3.4 Add New Variables with `mutate()`
#### 3.4.1 Useful Creation Functions
* *Arithmetic operators* `+`, `-`, `*`, `/`, `^`
* *Modular arithmetic* (`%/%` and `%%`)
%/% is integer division and %% is remainder
```{r Useful Creation Functions Note}
transmute(flights, dep_time,
          hour = dep_time %/% 100,
          minute = dep_time %% 100)
```
* *Logs* `log()`, `log()`, `log10()`
Logarithms are useful transformations for dealing with data ranges across multiple orders of magnitutde. They also convert multiplicative relationships to additive, a feature revisited in Part IV.

The book recommends `log2()` because it's easy to interpret: a difference of 1 on the log scale corresponds to doubling on the original scale and a difference of -1 corresponds to halving.

* *Offsets*
`lead()` and `lag()` refer to leading or lagging values, allowing to compute running differences `(x - lag(x))` or find when values change `(x != lag(x))`. They're mostly used with `group_by`.

* *Cumulative and rolling aggregates*
R has functions for running sums, products, mins, and maxes: `cumsum()`, `cumprod()`, `cummin()`, `cummax()`, and **dplyr** provides `cummean()` for cumulative means. Try **RcppRoll** package for computing rolling aggregates.

* *Logical comparisons* `<`, `<=`, `>`, `>=`, `!=`
Note: It is good practice to save interim values if you're using complex logical operations

* *Ranking* `min_rank()`, `row_number()`, `dense_rank()`, `percent_rank()`, `cume_dist()`

#### 3.4.2 Exercises
1. Currently `dep_time` and `sched_dep_time` are convenient to look at, but hard to compute with because they're not really continuous numbers. Convert them to a more convenient representation of number of minutes since midnight.
```{r 3.4.2.1 Exercise}
convert_minutes <- function(x) {
  x %/% 100 * 60 + x %% 100
}
mutate(flights,
       dep_time_mins = dep_time %/% 100 * 60 + dep_time %% 100,
       sched_dep_time_mins = sched_dep_time %/% 100 * 60 + sched_dep_time %% 100) %>%
  select(dep_time, dep_time_mins, sched_dep_time, sched_dep_time_mins)
```

2. Compare `air_time` with `arr_time` - `dep_time`. What do you expect to see? What do you see? What do you need to do to fix it? Account for time zones.
```{r 3.4.2.2 Exercise}
mutate(flights,
       diff = arr_time - dep_time) %>% 
  select(air_time, diff)
head(flights)
```

3. Compare `dep_time`, `sched_dep_time`, and `dep_delay`. How would you expect those three numbers to be related? I'd expect `dep_time` - `sched_dep_time` to be equal to `dep_delay`.
```{r 3.4.2.3 Exercise}
mutate(flights,
       dep_time_mins = convert_minutes(dep_time),
       sched_dep_time_mins = convert_minutes(sched_dep_time),
       dep_delay2 = dep_time_mins - sched_dep_time_mins) %>% 
  select(dep_delay, dep_delay2)
```

4. Find the 10 most delayed flights using a ranking function. How do you want to handle ties? Carefull read the documentation for `min_rank()`.
```{r 3.4.2.4 Exercise}
head(arrange(flights, min_rank(desc(flights$arr_delay))), 10)
```

5. What does `1:3 + 1:10` return? Why? It returns an error, because it is unable to do element-wise arithmetic with the lists not being divisible by one another.
```{r 3.4.2.5 Exercise}
1:3 + 1:10
```

6. What trigonometric functions does R provide? `cos`, `sin`, `tan`, `acos`, `asin`, `atan`, and some more.

### 3.5 Grouped Summaries with `summarize()`
#### 3.5.1 Counts
Whenever you use aggregation, it's always a good idea to include either `count (n()), or a count of nonmissing values (sum(!is.na(x))). This prevents you from making a conclusion based on small data. Example: planes identified by tail number that have highest average delays.
```{r 3.5.1.1 Counts Note}
not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarize(
    delay = mean(arr_delay)
  )
ggplot(data = delays, aes(x = delay)) +
  geom_freqpoly(binwidth = 10) +
  theme_minimal()
```

Delays go all the way out to 5 hours. But let's look at the count of the planes with extreme delays.
```{r 3.5.1.2 Counts Note}
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )
ggplot(data = delays, aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)
```

The author notes that there is greaster variation in the average delay when there are few flights. This plot shape is characteristic of plotting a mean or other summary versus group size will cause variation to decrease as the sample size increases.
It's a good idea to filter out groups with the smallest number of observations when looking at a plot like this
```{r 3.5.1.3 Counts Note}
delays %>% 
  filter (n > 25) %>% 
  ggplot(aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)
```

Plotting batting average (number of hits / number of attempts) of every major league baseball player.
Two noticable patterns:
* As above, variation decreases as sample size increases.
* A positive correlation between skill (ba) and opportunities at bat (ab), since teams tend to pick the 'best' players to have the most bat attempts.
```{r 3.5.1.4 Counts Note}
library(Lahman)
batting <- as_tibble(Batting)
batters <- batting %>% 
  group_by(playerID) %>% 
  summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )
batters %>% 
  filter(ab > 100) %>% 
  ggplot(aes(x = ab, y = ba)) +
  geom_point() +
  geom_smooth(se = FALSE)
```

Interestingly, if you take the data at face value, you will naively accept the highest ba batters as skill. Do you think one at bat constitutes skill for the ratio? Check http://bit.ly/Bayesbbal and http://bit.ly/notsortavg
```{r 3.5.4 Counts Note}
batters %>% 
  arrange(desc(ba))
```

#### 3.5.2 Useful Summary Functions
Aggregating with logical subsetting
```{r 3.5.2.1 Useful Summary Functions Note}
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    avg_delay1 <- mean(arr_delay),
    avg_delay2 <- mean(arr_delay[arr_delay > 0])
  )
```

*Measures of spread* `sd(x)`, `IQR(x)`, `mad(x)`
The standard deviation `sd(x)` is the stadnard measure of spread. The interquartile range `IQR(x)` or  median absolute deviation `mad(x)` are robust equivalents that may be more useful if you have outliers:
```{r 3.5.2.2 Useful Summary Functions Note}
# Why is the distance to some destinations more variable than others?
not_cancelled %>%
  as.tibble() %>% 
  group_by(dest) %>% 
  summarise(distance_sd = sd(distance)) %>% 
  arrange(desc(distance_sd))
```

*Measures of rank* `min(x)`, `quantile(x, .25)`, `max(x)`
Quantiles are generalizations of the median. A quantile will return a value that is greater than every value before it, but less than every value after. 

*Measures of position* `first(x)`, `nth(x, 2)`, `last(x)`
The three mentioned work similar to `x[1]`, `x[2]`, and `x[length(x)]` but let you set a default value if the position does not exist. The author mentions these complement filtering on ranks. Filtering gives you all the variables and each observation in a separate row. *I am not quite sure what this means. Should come back to it later. Revisit*
```{r 3.5.2.3 Useful Summary Functions Note}
not_cancelled %>% 
  group_by(year, month, day) %>% 
  mutate(r = min_rank(desc(dep_time))) %>% 
  filter(r %in% range(r))
```

*Counts*
We've used `n()` that counts the number of values in a specified group. `sum(!is.nax())` counts total non-missing values. `n_distinct(x)` counts unique values. 
```{r 3.5.2.4 Useful Summary Functions Note}
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))
```

Moreover, since counts are used frequently **dplyr** offers a simple way to employ the technique:
```{r 3.5.2.5 Useful Summary Functions Note}
not_cancelled %>% 
  count(dest)
```

You can count by a specified parameter. The author refers to this as a weight variable. Here the example counts (sum) the total number of miles a plane flew. I tried replicating this with other methods but was unsuccessful. Will come back to this, but this is an awesome, simple way to sum variables by another. *Revisit* *Figured it out in the exercises!*
```{r 3.5.2.6 Useful Summary Functions Note}
not_cancelled %>% 
  count(tailnum, wt = distance)
```

*Counts and proportions of logical values* `sum(x > 10)`, `mean(y == 0)`
This is pretty cool. When you combine logical values with numeric functions, `TRUE` is converted to 1 and `FALSE` is converted to 0. Thus, `sum()` gives you all the values that are `TRUE`, and `mean()` gives the proportion (number of 1's divided by total observations) of values that are `TRUE`.
```{r 3.5.2.7 Useful Summary Functions Note}
# How many flights left before 5am? these usually indicate delayed flights from the previous day
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(n_early = sum(dep_time < 500))
# What proportion of flights are delayed by more than an hour?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(hour_perc = mean(arr_delay > 60))
```

#### 3.5.3 Grouping by Multiple Variables
Author's note: be careful when progressively rolling up summaries: it's OK for sum and counts, but you need to think about weighting means and vasriances, and it's not possible to do it exactly for rank-based statistics like median. For example, the sum of groupwise sums is the overall sum, but the median of groupwise medians is not the true median.

#### 3.5.4 Ungrouping
Use `ungroup()` to remove grouping.

#### 3.5.5 Exercises
1. Brainstorm at least five different ways to assess the typical delay characteristics of a group of flights. Consider the following scenarios:

* A flight is 15 minutes early 50% of the time, and 15 minutes late 50% of the time.
* A flight is always 10 minutes late.
* A flight is 30 minutes early 50% of the time, and 30 minutes late 50% of the time.
* 99% of the time a flight is on time. 1% of the time it's 2 hours late. 

Which is more important: arrival delay or departure delay? Arrival delay is more important because time can be made up during the air if there is a departure delay. Also, consistency in delays can be computed, and will be a reliable estimate of actual arrival times. 

2. Come up with another approach that will give you the same output as `not_cancelled %>% count(dest) and not_cancelled %>% count(tailnum, wt = distance) without using count())`.
```{r 3.5.5.2 Exercise}
not_cancelled %>% 
  count(dest)
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(n = n())
not_cancelled %>% 
  count(tailnum, wt = distance)
not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(n = sum(distance))
```

3. Our definition of cancelled flights `(is.na(dep_delay)) | is.na(arr_delay)` is slightly suboptimal. Why? Which is the most important column? `dep_delay` could be `NA` or have a value (same for `arr_delay`). Therefore, using the `|` or operator will give a result when either are `NA`, but not both. To be more robust, we should specify with `&`. Note: `&` is the same as having multiple arguments separated by a comma.
```{r 3.5.5.3 Exercise}
filter(flights, is.na(dep_delay) & is.na(air_time))
```

4. Look at the number of cancelled flights per day. Is there a pattern? There seems to be peaks on the same days. I'm not sure why the 8th stands out as a frequent day of cancelled flights, or any of the other peak days.
```{r 3.5.5.4.1 Exercise}
flights %>% 
  group_by(day) %>% 
  summarise(cancelled = sum(is.na(dep_delay) & is.na(air_time))) %>% 
  arrange(day, desc(cancelled)) %>% 
  ggplot(aes(x = day, y = cancelled)) +
  geom_col() +
  scale_x_continuous(breaks = seq(1, 31, 1)) +
  theme_minimal()
```

Is the proportion of cancelled flights related to the average delay? There seems to be a positive linear relationship between average delay and cancelled flights. 
```{r 3.5.5.4.2 Exercise}
flights %>%
  group_by(year, month, day) %>%
  summarise(prop_cancelled = mean(is.na(dep_delay) & is.na(air_time)),
            avg_delay = mean(arr_delay, na.rm = TRUE)) %>%
  arrange(day, desc(avg_delay)) %>% 
  ggplot(aes(x = avg_delay, y = prop_cancelled)) +
  geom_point() +
  geom_smooth() +
  theme_minimal()
```

5. Which carrier has the worst delays? HA has the worst delays by absolutely value; however, if we consider other descriptive statistics such as average and median delay, HA falls to 6th worst. OO has the worst avg and median delays. 
```{r 3.5.5.5.1 Exercise}
not_cancelled %>% 
  group_by(carrier) %>% 
  summarise(max_dep_delay = max(dep_delay),
            max_arr_delay = max(arr_delay)) %>% 
  arrange(desc(max_dep_delay, max_arr_delay))
not_cancelled %>% 
  group_by(carrier) %>% 
  summarise(avg_dep_delay = mean(dep_delay[dep_delay > 0]),
            med_dep_delay = median(dep_delay[arr_delay > 0]),
            avg_arr_delay = mean(arr_delay[arr_delay > 0]),
            med_arr_delay = median(arr_delay[arr_delay > 0])) %>% 
  arrange(desc(avg_dep_delay, avg_arr_delay))
```

Challenge: can you disentangle the effects of bad airports versus bad carriers? Why/why not? (Hint: think about `flights %>% group_by(carrier, dest) %>% summarise(n())`. I'd posit that if there was an airport issue, you would see many different airlines responsible for delays by airport. Instead, the visualization below shows that airports that experience a high number of delays see very few (most of the time only 1) different airlines making up the population of delayed flights. This would lead one to attribute delayed flights to the carriers, rather than the actual airports.
```{r 3.5.5.5.2 Exercise}
flights %>% 
  group_by(carrier, dest) %>% 
  summarise(avg_arr_delay = mean(arr_delay[arr_delay > 0]),
            count = n()) %>%
  filter(!is.na(avg_arr_delay)) %>%
  ggplot() +
  geom_col(aes(x = dest, y = avg_arr_delay, fill = carrier)) +
  guides(fill = guide_legend(title = NULL)) +
  theme_minimal() +
  theme(legend.position = 'top') +
  theme(legend.text = element_text(size = 7, face = 'bold')) +
  theme(axis.text.x = element_text(size = 6))
# let's exclude carrier / destinastion combos that did not have more than 5 delays
flights %>% 
  group_by(carrier, dest) %>% 
  summarise(avg_arr_delay = mean(arr_delay[arr_delay > 0]),
            count = n()) %>%
  filter(!is.na(avg_arr_delay), count > 5) %>%
  ggplot() +
  geom_col(aes(x = dest, y = avg_arr_delay, fill = carrier)) +
  guides(fill = guide_legend(title = NULL)) +
  theme_minimal() +
  theme(legend.position = 'top') +
  theme(legend.text = element_text(size = 7, face = 'bold')) +
  theme(axis.text.x = element_text(size = 6))
```

6. For each plane, count the number of flights before the first delay of greater than 1 hour.
```{r 3.5.5.6 Exercise}
flights %>% 
  group_by(tailnum) %>%
  filter(arr_delay > 0 & arr_delay < 60) %>% 
  count(tailnum, sort = TRUE) 
```

7. What does the `sort` argument to `count()` do? When might you use it? It sorts output in ascending order. This is useful when you want to see the highest values.

### 3.6 Grouped Mutates (and Filters)
#### 3.6.1 Exercises
1. Refer back to the table of useful mutate and filtering functions. Describe how each operation changes when you combine it with grouping. The function is performed over each specified group rather than the entire data set.

2. Which plane `(tailnum)` has the worst on-time record? I performed this two ways: with `min_rank()` and through grouping and `summarise()`, though mutate was needed to add rank. 
```{r 3.6.1.2 Exercise}
# top ten worst by average arrival delay
not_cancelled %>%
  group_by(tailnum) %>%
  summarise(avg_arrdelay = round(mean(arr_delay)), 
            max_arrdelay = max(arr_delay)) %>%
  mutate(rank = dense_rank(desc(avg_arrdelay))) %>%
  filter(rank <= 10) %>% 
  arrange(desc(avg_arrdelay, max_arrdelay))
# highest arrival delay
not_cancelled %>% 
  filter(min_rank(desc(arr_delay)) == 1) %>% 
  select(tailnum, arr_delay)
```

3. What time of day should you fly if you want to avoid delays as much as possible?
```{r 3.6.1.3 Exercise}
not_cancelled %>% 
  group_by(hour) %>%
  summarise(arr_delay = round(mean(arr_delay), digits = 2),
            n()) %>% 
  arrange(arr_delay)
```

4. For each destination, compute the total minutes of delay. For each flight, compute the proportion of the total delay for its destination.
```{r 3.6.1.4 Exercise}
# using count
not_cancelled %>%
  filter(arr_delay > 0) %>% 
  count(dest, wt = arr_delay) %>% 
  arrange(desc(n))
# using group
not_cancelled %>% 
  group_by(dest) %>%
  filter(arr_delay > 0) %>% 
  mutate(total_delay = sum(arr_delay),
         prop_delay = arr_delay / sum(arr_delay))
# proportion pct
not_cancelled %>% 
  group_by(tailnum) %>%
  filter(arr_delay > 0) %>% 
  mutate(prop_delay_pct = arr_delay / sum(arr_delay) * 100) %>% 
  select(tailnum, dest, prop_delay_pct)
```

5. Delays are typically temporally correlated: even once the problem that caused the initial delay has been resolved, later flights are delayed to allow earlier flights to leave. Using `lag()` explores how the delay of a flight is related to the delay of the immediately preceding flight.
```{r 3.6.1.5 Exercise}
not_cancelled %>%
  group_by(year, month, day) %>%
  mutate(lag_delay = lag(dep_delay)) %>% 
  filter(!is.na(lag_delay)) %>% 
  ggplot(aes(x = lag_delay, y = dep_delay)) +
  geom_jitter(alpha = 1/20) +
  geom_smooth()
```

6. Look at each destination. Can you find flights that are suspiciously fast? (That is, flights that represent a potential data entry error.) Compute the air time of the flight relative to the shortest flight to that destination. Which flights were most delayed in the air?
```{r 3.6.1.6 Exercise}
not_cancelled %>% 
  group_by(dest) %>% 
  mutate(relative_air_time = air_time - min(air_time)) %>%
  filter(relative_air_time > 0) %>% 
  select(tailnum, air_time, dest, relative_air_time, dep_time, sched_dep_time) %>%
  arrange(desc(relative_air_time))
```

7. Find all the destinations that are flown by at least two carriers. Use that information to rank the carriers.
```{r 3.6.1.7 Exercise}
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(carriers = n_distinct(carrier)) %>%
  filter(carriers >= 2) %>% 
  mutate(rank = dense_rank(desc(carriers))) %>% 
  arrange(desc(carriers))
not_cancelled %>% 
  group_by(dest, carrier) %>%
  count(carrier) %>%
  group_by(carrier) %>%
  count(sort = TRUE)
```
