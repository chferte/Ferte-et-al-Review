## figureTwo.R

## Erich S. Huang
## Sage Bionetworks
## Seattle, Washington
## erich.huang@sagebase.org

## Visualizing the results of clinico-genomic models of 3-year overall survival in lung cancer

## REQUIRED LIBRARIES
require(synapseClient)
require(ggplot2)

## PULL DOWN THE predictiveModels.R WORKSPACE
predModEnt <- loadEntity('syn1447949')

# Unpack the workspace from the entity
objNames <- names(predModEnt$objects)
for(i in 1:length(predModEnt$objects)){
  varName <- objNames[i]
  targetObj <- predModEnt$objects[[i]]
  assign(varName, targetObj)
}

## ROC CURVES USING THE pROC OBJECTS
# Create a list of pROC objects
rocList <- list('clinical' = rocClin,
                'elasticnet' = rocEnet,
                'princomp' = rocPcr,
                'partleastsq' = rocPls,
                'randomforest' = rocRF)

aucCiList <- list('clinical' = txtClin,
                  'elasticnet' = txtEnet,
                  'princomp' = txtPcr,
                  'partleastsq' = txtPls,
                  'randomforest' = txtRF)

# Loop through the list. Had originally used lapply, but passing object names to the dataframes was
# unnnecessarily complicated using apply
rocDFList <- vector('list', length(rocList))
for(i in 1:length(rocList)){
  methodName <- names(rocList)[i]
  rocObject <- rocList[[i]]
  rocDF <- data.frame(rep(aucCiList[[i]], length(rocObject$specificities)),
                      1 - rocObject$specificities, rocObject$sensitivities)
  colnames(rocDF) <- c('Study', 'X', 'Y')
  rocDFList[[i]] <- rocDF
  names(rocDFList)[i] <- methodName
}

fullDF <- Reduce(rbind, rocDFList)

# Plot them
clinRocPlot <- ggplot(fullDF, aes(x = X, y = Y, group = Study)) + 
  geom_path(aes(colour = Study)) +
  geom_abline(slope = 1, colour = 'black') +
  opts(title = 'Receiver Operating Characteristic Curves\n') +
  xlab('1 - Specificity') +
  ylab('Sensitivity')
