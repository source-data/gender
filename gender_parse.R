
#!/usr/bin/env Rscript


########################################
######   libraries    ##################
########################################

require(dplyr)
require(readr)
require(mefa)
require(argparse)
require(XML)

########################################
######   argparse ######################
########################################

parser = ArgumentParser()
parser$add_argument('-i', '--input_file', help = 'Path to input text file containing names')
parser$add_argument('-nlines', '--num_lines_to_ignore', help = 'Number of lines to ignore in header of file')
args = parser$parse_args()

########################################
######   cleanup   #####################
########################################

if (file.exists('temp_genders.txt')){
    file.remove('temp_genders.txt')
}

########################################
######   data input   ##################
########################################

input_file = args$input_file
numlines = as.numeric(args$num_lines_to_ignore)
# input_file = 'EMBOJ_Track_record_2017.txt'
data = read_delim(file = input_file, skip = numlines, quote = "", delim = '\t', col_names = TRUE)

toRemove = grep('Manuscript', data$Manuscript)
data = data[-toRemove, ]

## Correct wrong encodings coming from eJP

html2txt <- function(str) {
      xpathApply(htmlParse(str, asText=TRUE), "//body//text()", xmlValue)[[1]] 
    } ## from https://stackoverflow.com/questions/5060076/convert-html-character-entity-encoding-in-r

data$Referee = sapply(data$Referee, function(x) html2txt(x))

########################################
######   data manipulation    ##########
########################################

## 1. Filter out 'No Reviewers'

data_without_noReviewers = data %>% filter(Referee != 'No Reviewers')

## 2. Split referees field, obtain clean list of referees' names

data_without_noReviewers$referees_clean = ''

num_reps = numeric()
for (line in 1:dim(data_without_noReviewers)[1]){
    # print(line)
    # print(data_without_noReviewers[line,])
    referees = unlist(strsplit(data_without_noReviewers$Referee[line], '#|,|a href'))
    names = grep('^ ([A-Z].*)( )([A-Z].*)|^([A-Z].*)( )([A-Z].*)', referees)
    names = referees[names]
    names = gsub('^ ', '', names)
    names = gsub('[ ]$', '', names)
    tooLong = which(nchar(names) > 40)
    if (length(tooLong) > 0) 
        {
            names = names[-which(nchar(names) > 40)]
        }
        else 
            {
            names = names
            }
    names = unique(names)
    # print(names)
    # print(length(names))
    num_reps[line] = length(names)
    # print(test)
    data_without_noReviewers$referees_clean[line] = paste0(unique(names), collapse = ',')
    data_without_noReviewers$referees_clean = as.character(data_without_noReviewers$referees_clean)
}

indiv_referees = unlist(strsplit(data_without_noReviewers$referees_clean, ','))

## 4. Transform table so that it will have 1 row per referee

data_without_noReviewers = rep(data_without_noReviewers[,], times = num_reps)

data_without_noReviewers = cbind(data_without_noReviewers, indiv_referees)

data_without_noReviewers$unique_id = c(1:length(data_without_noReviewers$indiv_referees))

## 5. Write out temp txt file containing the names of individual referees to pass through genderize

write.table(data_without_noReviewers[,c('unique_id', 'indiv_referees')], file = 'temp.txt', sep = '\t', row.names = FALSE, col.names = FALSE, quote = FALSE) 

system('python3 -m g temp.txt')

file.remove('temp.txt') # clean-up, remove temp.txt

print('Now merging file back to eJP report...')

## 6. Read gender txt file back in

gender = read.delim(file = 'temp_genders.txt', sep = '\t', header = TRUE)

## 7. Merge based on unique_id

final = merge(data_without_noReviewers, gender, by = 'unique_id', sort = FALSE, all.x = TRUE)

final = final[,c('unique_id', 'Manuscript', 'Editor', 'referees_clean', 'indiv_referees', 'name', 'gender', 'probability', 'count')]

outputFile = paste0(strsplit(input_file, '.txt')[[1]][1], '_annotated.txt')

write.table(final, file = paste0('webapp/results/', outputFile), sep = '\t', row.names = FALSE, quote = FALSE)

print(paste0('Results written to ', outputFile))

file.remove('temp_genders.txt')

#############################################
######   optional: data wranggling    #######
#############################################

# reread = read.delim(file = 'Track_record_2016_clean_with_gender_pred.txt', sep = '\t', header = TRUE)
# head(reread)

# gender_balance_by_ms = reread %>% group_by(Manuscript) %>%
# summarise(total = n(), male_count = sum(gender == 'male'), female_count = sum(gender == 'female')) %>%
# mutate(perc_male = male_count / total, perc_female = female_count / total)

# gender_balance_by_editor = reread %>% group_by(Editor) %>%
# summarise(total = n(), male_count = sum(gender == 'male'), female_count = sum(gender == 'female')) %>%
# mutate(perc_male = male_count / total, perc_female = female_count / total)


