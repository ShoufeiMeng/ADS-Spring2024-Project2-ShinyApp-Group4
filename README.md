# Project 2: Shiny App Development

### [Project Description](doc/project2_desc.md)

Term: Spring 2024

![screenshot](doc/figs/map.png)

## U.S. Disaster Analysis

+ **Team 4**
+ **Team Members**:
	+ Tianyi Xia
	+ Yang Yu
	+ Shoufei Meng
	+ Xiangjing Hu

+ **Project summary**: The project focuses on exploratory data analysis and visualization of US disaster information, encompassing the frequency of different disaster types and associated project costs across states, aiming to examine the short-term and long-term parttern of disaster happend in the US. We developed a shiny app that enable users to select a specific year, which then displays the frequency and cost data on the US map. The app also features histograms and ARIMA (AutoRegressive Integrated Moving Average) plots to provide detailed insights into disaster trends and financial impacts. This tool aims to enhance understanding and awareness of disaster patterns and their economic ramifications in the United States.

+ **Research Questions**:
	+ How do disaster frequencies vary among different states in the U.S. on an annual basis, and what patterns can be identified from these variations?
 	+ Which states have consistently experienced the highest number of different disasters per year, and how do these events correlate with losses in those states?
	+ How has the frequency of different disasters evolved over time across the U.S., and can any short-term or long-term trends be discerned from the data?

+ **Findings**:
	+ Severe weather and natural disasters are the two disasters that will have the greatest impact on the United States through 2020. The Southeast is highly impacted by severe weather. The central as well as the upper central part of the country is highly affected by natural disasters. However, in 2020, due to the emergence of a new coronavirus, every state in the U.S. is significantly impacted by it.The Lower Middle is significantly impacted by severe weather in 2021. Notably, California is significantly affected by severe weather and natural disasters in 2022 and 2023.
	+ According to our data framework, the disasters faced by different states are largely positively correlated with the costs they face. The size of the circle indicates the magnitude of the cost. However, it also appears that some disasters have a high frequency but not a high cost. Situations also emerged where the frequency of disasters was high but the costs were very large.
	+ For each state we constructed an ARIMA model and plotted its ACF and PACF to help us determine the order of the model. At the bottom we plotted the predictions of disaster frequency in the short term.

+ **Limitation & Future Extension**: In our map table there is only data for 2016-2023, indicating that there is still too little data available to us to be very powerful and convincing. In the histogram, some data for disasters are missing, which is why the x-axis is shown at positive infinity. If we want to show more convincing maps as well as time series predictions, we may need more data to show our ideas.

+ **Shiny App Link**: [https://helena-hu.shinyapps.io/US_Disaster_Shiny/](https://helena-hu.shinyapps.io/US_Disaster_Shiny/)

+ **Contribution statement**: All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement. We came up with the problem we wanted to study and filtered the appropriate dataset based on the problem. Shoufei Meng and Yang Yu pre-processed the data in the appropriate dataset. Shoufei undertaken the task of data cleansing and integration and engaged in  feature selection to identify the significant attributes of the data. Yang modeled the time series by the frequency of disasters and predicted it by a suitable ARIMA model. Tianyi is responsible for the ARIMA and descriptive statistics analysis sections in the Shiny app. For ARIMA forecasting, ACF and PACF plots are generated, along with time series forecasting and upper and lower confidence intervals. Xiangjing developed the map visualize disaster frequency and project cost of different kinds of disasters for each state in shiny app and deployed the shiny app. Xiangjing combined and organized the code and data and edit project and folder description.

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── app/
├── lib/
├── data/
├── doc/
└── output/
```

Please see each subfolder for a README file.

