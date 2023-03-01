# two functions to assign 3D tree model prototypes to each parameterized tree
# prerequisite are existing tree models, which vary in the relation between crown and trunk. 
# in the existing project 10 pre-modeled prototypes are defined
# the variety ranges from only crown to almost exclusively trunk. 

# function defines thresholds for assignment to the prototypes
# depending on number of prototypes
define_prototype_thresholds <- function(count_prototypes){
  
  # empty numeric vector 
  ratios_vector <- numeric(count_prototypes)
  
  # calculate ratios based on count of prototypes
  for(i in 0:(count_prototypes-1)){
    ratio <- (i/(count_prototypes-i))
    # append to vector
    ratios_vector[i+1] <- ratio
  }
  
  # empty numeric vector 
  thresholds_vector <- numeric(count_prototypes-1)
  
  # iterate over thresholds
  # last one would be division by zero, start loop at second item
  for(i in 2:(count_prototypes)){
    
    # calculate thresholds as mean distance between two ratios
    threshold <- (ratios_vector[i-1] + ratios_vector[i] ) / 2
    thresholds_vector[i-1] <- threshold
    
  }
  
  # return vector    
  return(thresholds_vector)
}


# function to assign the tree models 
# takes h_trunk, h_crown and the defined thresholds
assign_tree_model_ifelse <- function(h_trunk, h_crown, thresholds){
  ratio <- h_trunk / h_crown
  value <- ifelse(ratio < thresholds[1] & h_trunk < 0.1, "crown_10_trunk_0",
                  ifelse(ratio < thresholds[1] & h_trunk >= 0.1,  "crown_9_trunk_1",
                         ifelse(ratio >= thresholds[1] &  ratio < thresholds[2], "crown_9_trunk_1",
                                ifelse(ratio >= thresholds[2] &  ratio < thresholds[3], "crown_8_trunk_2",
                                       ifelse(ratio >= thresholds[3] &  ratio < thresholds[4], "crown_7_trunk_3",
                                              ifelse(ratio >= thresholds[4] &  ratio < thresholds[5], "crown_6_trunk_4",
                                                     ifelse(ratio >= thresholds[5] &  ratio < thresholds[6], "crown_5_trunk_5",
                                                            ifelse(ratio >= thresholds[6] &  ratio < thresholds[7], "crown_4_trunk_6",
                                                                   ifelse(ratio >= thresholds[7] &  ratio < thresholds[8], "crown_3_trunk_7",
                                                                          ifelse(ratio >= thresholds[8] &  ratio < thresholds[9], "crown_2_trunk_8", "crown_1_trunk_9")
                                                                   )
                                                            )
                                                     )
                                              )
                                       )
                                )
                         )
                  )
  )
  return(value)
}