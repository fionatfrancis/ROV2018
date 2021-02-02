ROV fish densities
================
Fiona Francis
2/2/2021

``` r
## SETUP -----------

#install.packages("tidyverse")
#install.packages("janitor")
library(janitor)
```

    ## Warning: package 'janitor' was built under R version 4.0.3

    ## 
    ## Attaching package: 'janitor'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     chisq.test, fisher.test

``` r
library(tidyverse)
```

    ## Warning: package 'tidyverse' was built under R version 4.0.3

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.0 --

    ## v ggplot2 3.3.2     v purrr   0.3.4
    ## v tibble  3.0.4     v dplyr   1.0.2
    ## v tidyr   1.1.2     v stringr 1.4.0
    ## v readr   1.4.0     v forcats 0.5.0

    ## Warning: package 'ggplot2' was built under R version 4.0.3

    ## Warning: package 'tibble' was built under R version 4.0.3

    ## Warning: package 'tidyr' was built under R version 4.0.3

    ## Warning: package 'readr' was built under R version 4.0.3

    ## Warning: package 'purrr' was built under R version 4.0.3

    ## Warning: package 'dplyr' was built under R version 4.0.3

    ## Warning: package 'stringr' was built under R version 4.0.3

    ## Warning: package 'forcats' was built under R version 4.0.3

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
# read in csvs
fish <- read_csv("2018_Vector_fish_with_coords.csv")
```

    ## 
    ## -- Column specification --------------------------------------------------------
    ## cols(
    ##   SurveyID = col_character(),
    ##   TranID_seg = col_character(),
    ##   Tran_Seg = col_double(),
    ##   TranID = col_character(),
    ##   Segment_num = col_double(),
    ##   GPS_time = col_time(format = ""),
    ##   DAYSEC = col_double(),
    ##   Species = col_character(),
    ##   UTM_LONG = col_double(),
    ##   UTM_LAT = col_double()
    ## )

``` r
habitat <-read_csv("ROV2018_Vector_SpeciesData.csv")
```

    ## 
    ## -- Column specification --------------------------------------------------------
    ## cols(
    ##   SurveyID = col_character(),
    ##   Segment_num = col_double(),
    ##   Video_time = col_time(format = ""),
    ##   GPS_time = col_time(format = ""),
    ##   PISCES_time = col_time(format = ""),
    ##   Species = col_character(),
    ##   Depth_m = col_double(),
    ##   Count = col_double(),
    ##   Segment_sum = col_logical(),
    ##   MicroSub1 = col_character(),
    ##   MicroSub2 = col_character(),
    ##   Biocover1 = col_character(),
    ##   Biocover2 = col_character(),
    ##   Relief = col_logical(),
    ##   Complexity = col_double(),
    ##   Hab_descrip = col_character(),
    ##   Species_Comments = col_character(),
    ##   SpeciesID = col_double(),
    ##   `View Pass` = col_double()
    ## )

``` r
status<- read_csv("Station_ID_RCA.csv")
```

    ## 
    ## -- Column specification --------------------------------------------------------
    ## cols(
    ##   .default = col_character(),
    ##   OBJECTID = col_double(),
    ##   Join_Count = col_double(),
    ##   TARGET_FID = col_double(),
    ##   Other_Pilo = col_logical(),
    ##   Other_Co_p = col_logical(),
    ##   Video_Star = col_time(format = ""),
    ##   Start_Lati = col_double(),
    ##   Start_Long = col_double(),
    ##   Video_2_St = col_logical(),
    ##   Click_to_c = col_double(),
    ##   ID = col_double(),
    ##   YR_CREATED = col_double(),
    ##   HECTARES = col_double(),
    ##   SQ_KM = col_double()
    ## )
    ## i Use `spec()` for the full column specifications.

``` r
## DATA CLEANING -----

head(fish)
```

    ## # A tibble: 6 x 10
    ##   SurveyID TranID_seg Tran_Seg TranID Segment_num GPS_time DAYSEC Species
    ##   <chr>    <chr>         <dbl> <chr>        <dbl> <time>    <dbl> <chr>  
    ## 1 Exp1     Exp1_P1_1         1 Exp1            10 12:48:44  46124 Yellow~
    ## 2 Exp1     Exp1_P1_1         1 Exp1            17 12:52:17  46337 Quillb~
    ## 3 Exp1     Exp1_P1_1         1 Exp1            57 13:12:26  47546 Quillb~
    ## 4 Exp2     Exp2_P1_1         1 Exp2            18 13:34:34  48874 Quillb~
    ## 5 Exp2     Exp2_P1_1         1 Exp2            20 13:35:39  48939 Quillb~
    ## 6 Exp2     Exp2_P1_1         1 Exp2            25 13:38:11  49091 Quillb~
    ## # ... with 2 more variables: UTM_LONG <dbl>, UTM_LAT <dbl>

``` r
summary(fish)
```

    ##    SurveyID          TranID_seg           Tran_Seg        TranID         
    ##  Length:1767        Length:1767        Min.   :1.000   Length:1767       
    ##  Class :character   Class :character   1st Qu.:1.000   Class :character  
    ##  Mode  :character   Mode  :character   Median :1.000   Mode  :character  
    ##                                        Mean   :1.833                     
    ##                                        3rd Qu.:2.000                     
    ##                                        Max.   :8.000                     
    ##                                        NA's   :184                       
    ##   Segment_num      GPS_time            DAYSEC        Species         
    ##  Min.   : 1.00   Length:1767       Min.   :27681   Length:1767       
    ##  1st Qu.:18.00   Class1:hms        1st Qu.:40407   Class :character  
    ##  Median :32.00   Class2:difftime   Median :48642   Mode  :character  
    ##  Mean   :31.69   Mode  :numeric    Mean   :47834                     
    ##  3rd Qu.:46.00                     3rd Qu.:56420                     
    ##  Max.   :72.00                     Max.   :66573                     
    ##                                                                      
    ##     UTM_LONG         UTM_LAT       
    ##  Min.   :355582   Min.   :5367942  
    ##  1st Qu.:372779   1st Qu.:5451115  
    ##  Median :415761   Median :5492279  
    ##  Mean   :417666   Mean   :5484492  
    ##  3rd Qu.:442034   3rd Qu.:5539252  
    ##  Max.   :509753   Max.   :5553345  
    ##  NA's   :184      NA's   :184

``` r
head(habitat)
```

    ## # A tibble: 6 x 19
    ##   SurveyID Segment_num Video_time GPS_time PISCES_time Species Depth_m Count
    ##   <chr>          <dbl> <time>     <time>   <time>      <chr>     <dbl> <dbl>
    ## 1 Explore1          10 04'34"     12:48:44 12:47:58    Yellow~      52     1
    ## 2 Explore1          17 08'07"     12:52:17 12:51:31    Quillb~      50     1
    ## 3 Explore1          57 28'16"     13:12:26 13:11:40    Quillb~      50     1
    ## 4 Explore2          18 09'16"     13:34:34 13:33:49    Quillb~      56     1
    ## 5 Explore2          20 10'21"     13:35:39 13:34:54    Quillb~      55     1
    ## 6 Explore2          25 12'53"     13:38:11 13:37:26    Quillb~      53     1
    ## # ... with 11 more variables: Segment_sum <lgl>, MicroSub1 <chr>,
    ## #   MicroSub2 <chr>, Biocover1 <chr>, Biocover2 <chr>, Relief <lgl>,
    ## #   Complexity <dbl>, Hab_descrip <chr>, Species_Comments <chr>,
    ## #   SpeciesID <dbl>, `View Pass` <dbl>

``` r
summary(habitat)
```

    ##    SurveyID          Segment_num     Video_time         GPS_time       
    ##  Length:1813        Min.   : 1.00   Length:1813       Length:1813      
    ##  Class :character   1st Qu.:18.00   Class1:hms        Class1:hms       
    ##  Mode  :character   Median :31.00   Class2:difftime   Class2:difftime  
    ##                     Mean   :31.64   Mode  :numeric    Mode  :numeric   
    ##                     3rd Qu.:46.00                                      
    ##                     Max.   :72.00                                      
    ##                                                                        
    ##  PISCES_time         Species             Depth_m          Count       
    ##  Length:1813       Length:1813        Min.   : 25.0   Min.   : 1.000  
    ##  Class1:hms        Class :character   1st Qu.: 58.0   1st Qu.: 1.000  
    ##  Class2:difftime   Mode  :character   Median : 72.0   Median : 1.000  
    ##  Mode  :numeric                       Mean   : 72.3   Mean   : 1.226  
    ##                                       3rd Qu.: 86.0   3rd Qu.: 1.000  
    ##                                       Max.   :165.0   Max.   :23.000  
    ##                                                                       
    ##  Segment_sum      MicroSub1          MicroSub2          Biocover1        
    ##  Mode :logical   Length:1813        Length:1813        Length:1813       
    ##  FALSE:1778      Class :character   Class :character   Class :character  
    ##  NA's :35        Mode  :character   Mode  :character   Mode  :character  
    ##                                                                          
    ##                                                                          
    ##                                                                          
    ##                                                                          
    ##   Biocover2          Relief          Complexity    Hab_descrip       
    ##  Length:1813        Mode:logical   Min.   :1.000   Length:1813       
    ##  Class :character   NA's:1813      1st Qu.:1.000   Class :character  
    ##  Mode  :character                  Median :2.000   Mode  :character  
    ##                                    Mean   :1.872                     
    ##                                    3rd Qu.:2.000                     
    ##                                    Max.   :4.000                     
    ##                                                                      
    ##  Species_Comments     SpeciesID      View Pass    
    ##  Length:1813        Min.   :3959   Min.   :1.000  
    ##  Class :character   1st Qu.:4785   1st Qu.:1.000  
    ##  Mode  :character   Median :6266   Median :1.000  
    ##                     Mean   :5930   Mean   :1.058  
    ##                     3rd Qu.:6726   3rd Qu.:1.000  
    ##                     Max.   :7221   Max.   :3.000  
    ##                     NA's   :45

``` r
summary(habitat$Species)
```

    ##    Length     Class      Mode 
    ##      1813 character character
