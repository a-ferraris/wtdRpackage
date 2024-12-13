
create_wtd <- function(id, dates, drug, year_wtd, 
                       prevalent = 0, 
                       random_index = FALSE,
                       set_seed = 788622, # See Soccer World Cup champions for these years. 
                       custom_date = NULL, 
                       delta = 365,
                       strata = NULL){
  # loading libraries. 
  if (!require("data.table")){install.packages("data.table")} 
  library(data.table)

  ## WTD estimation function
  date_index_wtd <- as.Date(paste0(as.character(year_wtd), "-01-01"), 
                            format = "%Y-%m-%d")
  date_index_wtd_reverse <- as.Date(paste0(as.character(year_wtd), "-12-31"), 
                                    format = "%Y-%m-%d")
  
  # create random date function()
  set.seed(set_seed)
  generate_random_date <- function(year) {
    start_date <- date_index_wtd
    end_date <- date_index_wtd_reverse
    as.Date(runif(1, as.numeric(start_date), as.numeric(end_date)), 
            origin = "1970-01-01")
  }
  
  # custom date
  if(is.null(custom_date) == FALSE){
    date_index_wtd <- as.Date(custom_date, format = "%Y-%m-%d")
    end_date <- date_index_wtd + 365
    message(paste0("Both Year ", as.character(year_wtd), " and a custom_date '", 
                   as.character(custom_date), "' were entered - WTD is calculated using custom date."))
  }
  
  # main function to estimate wtd days in its different forms and N of patients. 
  wtd_estimation <- function(data) {
                      # conventional WTD 
                      data[, wtd_days := round(as.numeric(difftime(dates, date_index_wtd), 
                                                    units = "days"), digits = 0)]
                      # remove impossible values
                      data[wtd_days < 0 | wtd_days > delta, wtd_days := NA]
                      # replace values with minimum value per patient. 
                      data[, wtd_days := min(wtd_days, na.rm = TRUE), 
                           by = list(patient_id, drug)]
                      
                      #reverse WTD
                      data[, wtd_days_reverse := round(as.numeric(difftime(date_index_wtd_reverse,
                                                                     dates), units = "days"), digits = 0)]
                      
                      data[wtd_days_reverse < 0 | wtd_days_reverse > delta, wtd_days_reverse := NA]
                      
                      data[, wtd_days_reverse := min(wtd_days_reverse, na.rm = TRUE), 
                           by = list(patient_id, drug)]
                      
                      # random indexes
                      # create a random index per patient per drug.
                      data[, random_date := generate_random_date(year_wtd), 
                           by = list(patient_id, drug)]    
                      # estimate conventional WTD
                      data[, wtd_days_random := round(as.numeric(difftime(dates, random_date), 
                                                           units = "days"), digits = 0)]
                      # estimate reverse WTD
                      data[, wtd_days_random_reverse := round(as.numeric(difftime(random_date, dates), 
                                                                   units = "days"), digits = 0)]
                      
                      # remove impossible values
                      data[wtd_days_random < 0 | wtd_days_random > delta, wtd_days_random := NA]
                      data[wtd_days_random_reverse < 0 | wtd_days_random_reverse > delta, wtd_days_random_reverse := NA]
                      
                      # keep only the minimum value (i.e., distance of the first prescription). 
                      data[, wtd_days_random := min(wtd_days_random, na.rm = TRUE), 
                           by = list(patient_id, drug)]
                      
                      data[, wtd_days_random_reverse := min(wtd_days_random_reverse, na.rm = TRUE), 
                           by = list(patient_id, drug)]
                  }
    ## check format of input variables. ----
  check_atomic <- function(variables, var_names) {
                  for (i in seq_along(variables)) {
                    if (!is.atomic(variables[[i]])) {
                      stop(paste0("error: ", var_names[[i]], 
                                  " must be entered as an atomic vector"))
      }}}

  check_atomic(list(dates, id, drug), c("dates", "id", "drug", "strata"))
  
  if(!(is.numeric(prevalent) && (!is.integer(prevalent) | prevalent == 0 )) | prevalent < 0){
      stop("'prevalent' option must be a numeric integer >= 0")}
  
  ## check length of vectors - STOP if not the same.----
  if(!((length(dates) == length(id)) && (length(id) == length(dates)))){
      stop("error: arguments have different length")} 
    
  ## creating a data.table object to optimize speed ----
  dates <- as.Date(dates, format = "%Y-%m-%d") 
  
  if(all(is.null(strata)) == TRUE){ # if no strata is specified
                  wtd <- data.table(patient_id = id, 
                                    dates = dates, 
                                    drug = drug
                                    )
  } else {
                  wtd <- data.table(patient_id = id, 
                                    dates = dates, 
                                    drug = drug, 
                                    strata = strata
    )
  }
  ## checking NAs.----
   if(any(is.na(wtd)) ==  TRUE){ 
            n_initial <- length(wtd$patient_id)
            wtd <- na.omit(wtd) # complete cases only
            
            n_after <- length(wtd$patient_id)
            n_nas <- as.character(n_initial - n_after)
            # inform N of removed rows
            message(paste0(n_nas, " NAs were present and they were removed"))
          }
        
          # create a 'year', var to make wrangling easier down the road. 
          wtd[, year_prescription := format(dates, "%Y"), 
                                     by = patient_id]
          
          # ordering data.table by drug and date of prescription  
          wtd <- wtd[order(id, dates)]
          
          # is prevalent > 0? keep only prevalent. 
          if(prevalent > 0) {
            # we extract the observations in the year preceding year of interest.
            prevalent_users <- wtd[year_prescription == (year_wtd - 1), ]
            # we now count the number of rows (== n of prescriptions for a given drug)
            prevalent_users <- prevalent_users[order(patient_id, drug)]
            prevalent_users <- prevalent_users[, n_prescriptions := seq_len(.N), 
                                               by = list(patient_id, drug)]
            # we keep observations with the same number or more of prescriptions in the preceding year
            prevalent_users[, max_n_prescriptions := max(n_prescriptions, na.rm = TRUE), 
                                                 by = list(patient_id, drug)]
            prevalent_users <- prevalent_users[max_n_prescriptions >= prevalent, ]
            # keeping ids and sub-setting the dataset
            prevalent_users <- prevalent_users$patient_id
            wtd <- wtd[patient_id %in% prevalent_users]
         } 
          # since it is possible to have random indexes, keep the year
          # that precedes and follows the year of interest. 
          # wtd_estimation gets rid of values beyond 365 years/negative ones. 
          wtd <- wtd[year_prescription == year_wtd | year_prescription == (year_wtd - 1) |
                       year_prescription == year_wtd + 1, ]
                    
          # now, we estimate wtd. 
          wtd_estimation(wtd)
          # remove duplicates
          wtd <- wtd[, n_observation :=  seq_len(.N), by = list(patient_id, drug)]
          wtd <- wtd[n_observation == 1, ]
          # keep only one observation per patient and for the year of interest. 
          if(random_index == TRUE){
            wtd <- wtd[, list(patient_id, drug, strata, 
                              wtd_days, wtd_days_reverse, 
                              wtd_days_random, wtd_days_random_reverse)]
            # keep only one value per patient per drug. 

          } else {
            wtd <- wtd[, list(patient_id, drug, strata, 
                            wtd_days, wtd_days_reverse)]
          }
          wtd <- as.data.frame(wtd)
 return(wtd)
}

##########
##########
##########
##########
##########
# summarise_wtd() ----
summarise_wtd <- function(wtd_data, 
                          probability = 0.8,
                          strata = FALSE, 
                          random_index = FALSE, 
                          min_number = 100){
# loading libraries. 
            if(!require("data.table")) {install.packages("data.table")} else {
             library(data.table)}
            
  # checking probability value
  if(!is.numeric(probability) | probability < 0 | probability > 1){
    stop("probability must be a numeric value > 0 and < 1")}
  
            wtd_data <- as.data.table(wtd_data)
            wtd_summary <- copy(wtd_data)
            
            wtd_summary <- wtd_summary[, `:=`("N_patients" = .N,
                                             "wtd_days" = quantile(wtd_days, 
                                                                   probability, na.rm = TRUE),
                                             "wtd_days_reverse" = quantile(wtd_days_reverse, 
                                                                           probability, na.rm = TRUE),
                                             "strata" =  "overall"), 
                                      by = list(drug)]
            
            if(random_index == TRUE){
              wtd_summary <-  wtd_summary[, `:=`("wtd_days_random" = quantile(wtd_days_random, 
                                                              probability, na.rm = TRUE),
                                 "wtd_days_random_reverse" = quantile(wtd_days_random_reverse, 
                                                                      probability, na.rm = TRUE) 
                                 ),
                          by = list(drug)]
              
              wtd_summary <- wtd_summary[is.na(wtd_days_random) ==  FALSE, 
                                         N_patients_wtd_random := .N, 
                                   by = list(drug)]
              
              wtd_summary <- wtd_summary[is.na(wtd_days_random_reverse) == FALSE, 
                                         N_patients_wtd_random_reverse := .N, 
                                   by = list(drug)]
              
              wtd_summary <- wtd_summary[, N_patients_wtd_random := max(N_patients_wtd_random, 
                                                                        na.rm = TRUE), 
                                   by = list(drug)]
              
              wtd_summary <- wtd_summary[, N_patients_wtd_random_reverse := max(N_patients_wtd_random_reverse, 
                                                                                na.rm = TRUE), 
                                   by = list(drug)]
            }
            
            wtd_summary <- wtd_summary[, n_observation := seq_len(.N), 
                                       by = drug]
            
            wtd_summary <- wtd_summary[n_observation == 1]
            
            wtd_summary <- wtd_summary[, -c("n_observation")]
            
    
    # if a stratified summary is required, this chunk kicks in with random_index options
    if(strata == TRUE && random_index == FALSE){
              wtd_data$strata <- as.factor(wtd_data$strata)
      
              wtd_data <- wtd_data[, `:=`("N_patients" = .N,
                                          "wtd_days" = quantile(wtd_days, 
                                                                probability, na.rm = TRUE),
                                          "wtd_days_reverse" = quantile(wtd_days_reverse, 
                                                                        probability, na.rm = TRUE) 
                                          ), 
                                   by = list(drug, strata)]
              
              wtd_data[, n_observation := seq_len(.N), 
                       by = list(drug, strata)]      
              
              wtd_data <- wtd_data[n_observation == 1]
              wtd_data <- wtd_data[, -c("n_observation")]
              
              wtd_summary <- rbind(wtd_summary, wtd_data)
     
              }
            
    if(strata == TRUE && random_index == TRUE){
              wtd_data$strata <- as.factor(wtd_data$strata)
              
              wtd_data <- wtd_data[is.na(wtd_days) == FALSE, `:=`("N_patients" = .N,
                                          "wtd_days" = quantile(wtd_days, 
                                                                probability, na.rm = TRUE),
                                          "wtd_days_reverse" = quantile(wtd_days_reverse, 
                                                                        probability, na.rm = TRUE), 
                                          "wtd_days_random" = quantile(wtd_days_random, 
                                                                       probability, na.rm = TRUE),
                                          "wtd_days_random_reverse" = quantile(wtd_days_random_reverse, 
                                                                               probability, na.rm = TRUE)
                                          ), 
                                          by = list(drug, strata)]
              
              wtd_data <- wtd_data[is.na(wtd_days_random) == FALSE, N_patients_wtd_random := .N, 
                                    by = list(drug, strata)]
              
              wtd_data <- wtd_data[is.na(wtd_days_random_reverse) == FALSE, N_patients_wtd_random_reverse := .N, 
                                   by = list(drug, strata)]
              wtd_data <- wtd_data[, N_patients_wtd_random := max(N_patients_wtd_random, na.rm = TRUE), 
                                   by = list(drug, strata)]
              wtd_data <- wtd_data[, N_patients_wtd_random_reverse := max(N_patients_wtd_random_reverse, na.rm = TRUE), 
                                   by = list(drug, strata)]
              
            wtd_data[, n_observation := seq_len(.N), 
                     by = list(drug, strata)]      
            
            wtd_data <- wtd_data[n_observation == 1]
            wtd_data <- wtd_data[, -c("n_observation")]
            
            wtd_summary <- rbind(wtd_summary, wtd_data)
    }
            
  wtd_summary <- wtd_summary[order(drug, strata)]
  
  
  if(any(wtd_summary$N_patients < min_number)){
    wtd_low <- wtd_summary[N_patients < min_number]
    wtd_low <- wtd_low[, c("drug")]
    wtd_low <- unique(wtd_low)
    message(paste0("warning: ", as.character(wtd_low), 
                   " had < 100 observations and estimates may be inaccurrate"))
  }
  
  if(random_index == TRUE){
    wtd_summary <- wtd_summary[, list(drug, strata, 
                                      N_patients, N_patients_wtd_random,
                                      N_patients_wtd_random_reverse, 
                                      wtd_days, wtd_days_reverse, 
                                      wtd_days_random, 
                                      wtd_days_random_reverse)]
    
    wtd_summary <- as.data.frame(wtd_summary)
    
    colnames(wtd_summary) <- c("drug", "strata", "N_patients",
                               "N_patients_wtd_random",
                               "N_patients_wtd_random_reverse",
                               paste0("wtd_days_", as.character(probability*100), 
                                      "th pc"), 
                               paste0("wtd_days_reverse_", as.character(probability*100), 
                                      "th pc"), 
                               paste0("wtd_days_random", as.character(probability*100), 
                                      "th pc"), 
                               paste0("wtd_days_random_reverse", as.character(probability*100), 
                                      "th pc"))
    
  } else {
  wtd_summary <- wtd_summary[, list(drug, strata, N_patients, 
                                    wtd_days, wtd_days_reverse)]
  wtd_summary <- as.data.frame(wtd_summary)
  
  colnames(wtd_summary) <- c("drug", "strata", "N_patients", 
                             paste0("wtd_days_", as.character(probability*100), 
                                    "th pc"), 
                             paste0("wtd_days_reverse_", as.character(probability*100), 
                                    "th pc"))
  }
  return(wtd_summary)
}

####
####
#### ECDF plot -----
ecdf_wtd <- function(wtd_data, 
                     probability = 0.8,
                     wtd_palette = "Set3",
                     color_blind = FALSE,
                     distribution = "wtd_days", 
                     lines = TRUE,
                     strata = FALSE, 
                     min_number = 100) {
  
  # loading libraries. 
  if (!require("RColorBrewer")){install.packages("RColorBrewer")} 
  if (!require("tidyverse")){install.packages("tidyverse")} 
  if (!require("cols4all")){install.packages("cols4all", dependencies = TRUE)} 
  
  library(tidyverse)
  library(RColorBrewer)
  library(cols4all)
  
  options_palette <- c("Blues", "BuGn", "BuPu", "GnBu", "Greens", "Greys", 
                       "Oranges", "OrRd", "PuBu", "PuBuGn", "PuRd", "Purples", 
                       "RdPu", "Reds", "YlGn", "YlGnBu", "YlOrBr", 
                      "YlOrRd", "BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", 
                      "RdYlBu", "RdYlGn", "Spectral", "Accent", "Dark2", "Paired", 
                      "Pastel1", "Pastel2", "Set1", "Set2", "Set3")
   
  if(!wtd_palette %in% options_palette){
    message(paste0("invalid palette option. Default wtd_palette is 'Set3'. 
                Valid options are ")) 
                print(options_palette)
                stop("fix 'palette' option")}
  
  options_distribution <- c("wtd_days", "wtd_days_reverse", 
                            "wtd_days_random", "wtd_days_random_reverse")
  
  if(!distribution %in% options_distribution){
    message(paste0("error: invalid 'distribution' option. valid options are "))
         print(paste(as.character(options_distribution), sep = ", "))
         stop("fix 'distribution' option.")
  }
  
  if(color_blind == TRUE && (wtd_palette != "Set3")){
    message("Both a custom palette was selected and 'colorblind' is on: colors
            are colorblind friendly but the custom palette was not used")}
  # selecting column of wtd distribution of interest. 
  wtd_data$wtd_plot <- wtd_data[[distribution]]
  # removing NAs
  wtd_data <- wtd_data[is.na(wtd_data$wtd_plot) == FALSE, ]
  
  # keep only drugs with >=100 observations 
  wtd_data <- wtd_data %>% group_by(drug) %>% 
                mutate(N_patients = n())
  
  # keep only drugs with a minimum number of observations(custom)
  if(any(wtd_data$N_patients < min_number)){
    wtd_low <- wtd_data %>% filter(N_patients < min_number)
    wtd_low <- unique(wtd_low$drug) 
    wtd_data <- wtd_data[! wtd_data$drug %in% wtd_low, ]
    message(paste0("warning: ", "the following drugs had <", as.character(min_number), 
                   " observations they were excluded from the analysis."))
    print(paste(as.character(wtd_low), sep = ", "))
  }
  
  # Generate a palette
  generate_palette <- function(n, palette = wtd_palette) {
    colorRampPalette(brewer.pal(min(n, brewer.pal.info[palette, "maxcolors"]), 
                                palette))(n)}
  
  # Generate list of drug/color to iterate over  
  drugs_unique <- unique(wtd_data$drug)
  ecdf_colors <- generate_palette(n = length(drugs_unique), 
                                  wtd_palette)
  
  # if colorblind friendly on, create a colorblind-friendly list of colors
  if(color_blind == TRUE){
    ecdf_colors <- c4a("hcl.purple_brown", length(drugs_unique))}
  
  # use a data frame to merge it later. 
  drugs_unique <- data.frame(drug_name = drugs_unique, 
                             color = ecdf_colors)
  
  # create a list with the names of drugs present in the dataset. 
  drugs_to_plot <- list()
  for(d in drugs_unique$drug_name){
    drugs_to_plot[[d]]$name <- d
    drugs_to_plot[[d]]$color <- drugs_unique$color[drugs_unique$drug_name == d]
  }
  
  # iterate over the list to generate separate plots for each drug. 
  for(drug in names(drugs_to_plot)) {
    # subset only the drug of interest
    p <- wtd_data[wtd_data$drug == drug, ]
    # select color
    color <- drugs_to_plot[[drug]]$color
    # create plot
    p <- p %>% 
      ggplot(aes(x = wtd_plot)) +
      stat_ecdf(geom = "step", color = color, linewidth = 1) + 
      geom_point(stat = "ecdf", color = color, 
                 size = 2, alpha = 0.6) +  # points
      labs(
        title = paste0("Empirical cumulative distribution of ", 
                       drug),
        x = "WTD days",
        y = "ECDF",
        caption = "Data: empirical distribution"
      ) +
      theme_classic(base_size = 15) +  
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.caption = element_text(hjust = 1, face = "italic"),
        axis.title = element_text(face = "bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
      )  
     # add lines if desired (custom)
    if(lines == TRUE){
      p <- p + 
        geom_vline(xintercept = quantile(wtd_data$wtd_plot[wtd_data$drug == drug], 
                                         probs = probability, na.rm = TRUE), 
                   linetype = "dashed", color = "grey") +
        geom_hline(yintercept = probability, linetype = "dashed", color = "grey")
    }

  drugs_to_plot[[drug]] <- p # saving object in list
  
  rm(p, drug)
  }
  
  # overal plot of all ECDF functions----
  wtd_data <- merge(x = wtd_data, y = drugs_unique, by.x = "drug",
                    by.y = "drug_name", 
                    all.x = TRUE)
  
  drugs_to_plot$pooled_ecdf_plot <- ggplot(wtd_data, aes(x = wtd_plot, 
                                                         color = color)) +
                                            stat_ecdf(geom = "step", 
                                                      linewidth = 0.8) +
                                            facet_wrap(~drug, 
                                                       scales = "free_y") + 
                                            labs(title = "Empirical Cumulative Distribution Function (ECDF) of WTD Days by Drug",
                                                 x = "WTD Days",
                                                 y = "Cumulative Probability") +
                                            theme_minimal() + 
                                            theme(legend.position = "none")
  
  
  # Plot ECDF + Histogram using counts for all drugs -----
  drugs_to_plot$pooled_ecdf_hist_plot <- ggplot(wtd_data, aes(x = jitter(wtd_plot, 
                                                                         amount = 0.5), 
                                                              fill = color)) +
                                                geom_histogram(aes(y = after_stat(count), 
                                                                   color = color), 
                                                               binwidth = 8, 
                                                               alpha = 0.9) +
                                               facet_wrap(~drug, scales = "free_y") + 
                                                labs(
                                                  title = "ECDF and Histogram of WTD Days by Drug",
                                                  subtitle = "Histogram showing the count of WTD Days with ECDF overlay",
                                                  x = "WTD Days",
                                                  y = "Count"
                                                ) +
                                                theme_minimal(base_size = 14) +
                                                theme(
                                                  panel.grid.minor = element_blank(),
                                                  panel.grid.major = element_line(color = "grey90"),
                                                  strip.text = element_text(face = "bold", size = 12),
                                                  plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
                                                  plot.subtitle = element_text(size = 14, hjust = 0.5)) + 
                                                theme(legend.position = "none")
  
  print(drugs_to_plot$pooled_ecdf_plot)
  print(drugs_to_plot$pooled_ecdf_hist_plot)
  return(drugs_to_plot)
}

##########
##########
##########
##########
hist_wtd <- function(wtd_data, 
                     wtd_palette = "Set3",
                     color_blind = FALSE,
                     strata = FALSE, 
                     distribution = "wtd_days", 
                     min_number = 100) {
  
  # loading libraries. 
  if (!require("RColorBrewer")){install.packages("RColorBrewer")} 
  if (!require("tidyverse")){install.packages("tidyverse")} 
  if (!require("cols4all")){install.packages("cols4all", dependencies = TRUE)} 
  
  library(tidyverse)
  library(RColorBrewer)
  library(cols4all)
  
  options_palette <- c("Blues", "BuGn", "BuPu", "GnBu", "Greens", "Greys", 
                       "Oranges", "OrRd", "PuBu", "PuBuGn", "PuRd", "Purples", 
                       "RdPu", "Reds", "YlGn", "YlGnBu", "YlOrBr", 
                       "YlOrRd", "BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", 
                       "RdYlBu", "RdYlGn", "Spectral", "Accent", "Dark2", "Paired", 
                       "Pastel1", "Pastel2", "Set1", "Set2", "Set3")
  
  
  options_distribution <- c("wtd_days", "wtd_days_reverse", 
                            "wtd_days_random", "wtd_days_random_reverse")
  
  if(!wtd_palette %in% options_palette){
    message(paste0("error: invalid 'palette' option.  Default wtd_palette is 'Set3'.
                   valid options from the RColorBrewer package are "))
    print(as.character(options_palette))
    stop("fix 'palette' option.")
  }
  
  if(!distribution %in% options_distribution){
    message(paste0("error: invalid 'distribution' option. valid options are "))
    print(as.character(options_distribution))
    stop("fix 'distribution' option.")
  }
  
  if(color_blind == TRUE && (wtd_palette != "Set3")){
    message("Both a custom palette was selected and 'colorblind' is on: colors
            are colorblind friendly but the custom palette was not used")}
  
  # selecting column of wtd distribution of interest. 
  wtd_data$wtd_plot <- wtd_data[[distribution]]
  # removing NAs
  wtd_data <- wtd_data[is.na(wtd_data$wtd_plot) == FALSE, ]
  
  # keep only drugs with >=100 observations (can be custom)
  wtd_data <- wtd_data %>% group_by(drug) %>% 
    mutate(N_patients = n())
  
  if(any(wtd_data$N_patients < min_number)){
    wtd_low <- wtd_data %>% filter(N_patients < min_number)
    wtd_low <- unique(wtd_low$drug) 
    wtd_data <- wtd_data[! wtd_data$drug %in% wtd_low, ]
    message(paste0("warning: ", "the following drugs had <", as.character(min_number), 
                   " observations they were excluded from the analysis."))
    print(paste(as.character(wtd_low), sep = ", "))
  }
  
  # Generate a palette----
  generate_palette <- function(n, palette = wtd_palette) {
    colorRampPalette(brewer.pal(min(n, brewer.pal.info[palette, "maxcolors"]), 
                                palette))(n)
  }
  
  # Generate list to iterate over  
  drugs_unique <- unique(wtd_data$drug)
  ecdf_colors <- generate_palette(n = length(drugs_unique), 
                                  wtd_palette)
  
  # if colorblind friendly on, create a colorblind-friendly list of colors
  if(color_blind == TRUE){
    ecdf_colors <- c4a("hcl.purple_brown", length(drugs_unique))
  }
  
  drugs_unique <- data.frame(drug_name = drugs_unique, 
                             color = ecdf_colors)
  
  drugs_to_plot <- list()
  for(d in drugs_unique$drug_name){
    drugs_to_plot[[d]]$name <- d
    drugs_to_plot[[d]]$color <- drugs_unique$color[drugs_unique$drug_name == d]
  }
  
  # iterate to generate separate plots. 
  for(drug in names(drugs_to_plot)) {
    p <- wtd_data[wtd_data$drug == drug, ]
    
    color <- drugs_to_plot[[drug]]$color
    
    p <- p %>% 
      ggplot(aes(x = wtd_plot)) +
      geom_histogram(binwidth = 10, fill = color, 
                     color = "black", alpha = 0.7) +  # histogram
      labs(
        title = paste0("Histogram of WTD days for ", 
                       drug),
        x = "WTD days",
        y = "Count"
      ) +
      theme_classic(base_size = 15) +  
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.caption = element_text(hjust = 1, face = "italic"),
        axis.title = element_text(face = "bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
      )  
    
    drugs_to_plot[[drug]] <- p # saving object in list
    
    rm(p, drug)
  }
  
  # overal plot of all ECDF functions----
  wtd_data <- merge(x = wtd_data, y = drugs_unique, by.x = "drug",
                    by.y = "drug_name", 
                    all.x = TRUE)
  
  drugs_to_plot$pooled_ecdf_plot <- ggplot(wtd_data, aes(x = wtd_plot, 
                                                         color = color)) +
    stat_ecdf(geom = "step", 
              linewidth = 0.8) +
    facet_wrap(~drug, 
               scales = "free_y") + 
    labs(title = "Empirical Cumulative Distribution Function (ECDF) of WTD Days by Drug",
         x = "WTD Days",
         y = "Cumulative Probability") +
    theme_minimal() + 
    theme(legend.position = "none")
  
  
  # Plot Histogram using counts for all drugs -----
  drugs_to_plot$pooled_ecdf_hist_plot <- ggplot(wtd_data, aes(x = jitter(wtd_plot, 
                                                                         amount = 0.5), 
                                                              fill = color)) +
    geom_histogram(aes(y = after_stat(count), 
                       color = color), 
                   binwidth = 8, 
                   alpha = 0.9) +
    facet_wrap(~drug, scales = "free_y") + 
    labs(
      title = "Histogram of WTD Days by Drug",
      subtitle = "Histogram showing the count of WTD Days",
      x = "WTD Days",
      y = "Count"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90"),
      strip.text = element_text(face = "bold", size = 12),
      plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
      plot.subtitle = element_text(size = 14, hjust = 0.5)) + 
    theme(legend.position = "none")
  
  print(drugs_to_plot$pooled_ecdf_plot)
  print(drugs_to_plot$pooled_ecdf_hist_plot)
  return(drugs_to_plot)
}
