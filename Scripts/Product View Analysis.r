---
  title: "R Notebook"
output: html_notebook
---
  
  This is an [R Markdown](http://rmarkdown.rstudio.com) Notebook. When you execute code within the notebook, the results appear beneath the code. 

```{r message=TRUE}
#install and load package arules
library(arules)
library(arulesViz)
library(readxl)
library(plyr)
library(dplyr)
library(arulesViz)
library(colorspace)
library(RColorBrewer)
library(shinythemes)
library(readr)
library(ExPanDaR)
```

```{r}
#October 2019
retail <- read_csv("../Data/Raw/ReportSingleDay.csv", col_types = cols(`MCVID (v29) (evar29)` = col_character()))
colnames(retail) <- c("mcvid","evar66", "products", "views")

#Import the Product Category Mappings for each Product.
#product_cat <- read_csv("product_cat.csv", col_types = cols(`Product Views` = col_skip(), Products = col_skip()))

#Update Column names
#names(product_cat) <- c("evar66","category")
#product_cat <- product_cat[complete.cases(product_cat),]

#Delete Columns and Update Names
retail$`Shop - Product ID (v66) (evar66)`<- NULL
retail$segment.id <- NULL
retail$segment.name <- NULL

retail <- retail[complete.cases(retail), ]
retail <- merge(retail, product_cat, by = "evar66")

InvoiceNo <- as.numeric(as.character(retail$evar69))
cbind(retail,InvoiceNo)
glimpse(retail)
#ExPanD(retail)

#Check format
write.csv(retail,"retail_transactions.csv", quote = TRUE, row.names = FALSE)

```


```{r}
transactionData <- ddply(retail,c("InvoiceNo"),function(df1)paste(df1$product,collapse = ","))
#Remove unneeded columns
transactionData$InvoiceNo <- NULL

#Rename column to items
colnames(transactionData) <- c("items")

#Check format
write.csv(transactionData,"market_basket_transactions.csv", quote = FALSE, row.names = FALSE)
```


```{r}
#Read in the transaction data into basket format
tr <- read.transactions('market_basket_transactions.csv', format = 'basket', sep=',')
#Check transactions
df_tr <- as(tr, "data.frame")
#Show summary of the transaction data
summary(tr)
```


```{r}
#Generate the Apriori Rules
# Min Support as 0.001, confidence as 0.001.
association.rules <- apriori(tr, parameter = list(supp=0.001, conf=0.001,maxlen=10, minlen = 1))
summary(association.rules)
df_association.rules<- as(association.rules, "data.frame")
```


```{r include=FALSE}
#Do the Magic, Abracadabra!
ruleExplorer(association.rules)
```