import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import seaborn as sns
import statsmodels.api as sm
from scipy.stats import ttest_ind
from scipy.stats import linregress

# Matplotlib Params and Colors

plt.rcParams['axes.facecolor']='white'
plt.rcParams['savefig.facecolor']='white'

colors = {'sindh': "peru",
         'punjab': "forestgreen"}

# Ticker for Millions

@mtick.FuncFormatter
def million_formatter(x, pos):
    return "%.1fM" % (x/1E6)

# Load Main DF and Agriculture Production DF

df = pd.read_csv("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/combined_province_1964_2019.csv")
df_agri = pd.read_csv("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/agriculture_production_hist.csv")
df_agri["Province"] = df_agri["Province"].apply(lambda x: x.lower())

# Figure 2 WAA Allocation

df_waa_delta = df.loc[df['period_beginning_in'] > 1991].pivot(values='delta_waa_allocation', index="period_beginning_in", columns="province")

fig, ax1 = plt.subplots(figsize=(10,5))

df_waa_delta.plot(kind='bar', ax=ax1, color=colors, xlabel='', ylabel='Deficit', rot=45)
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.axhline(y=df.groupby('province')['delta_waa_allocation'].mean()['punjab'], color=colors['punjab'], linestyle='dashed')
ax1.axhline(y=df.groupby('province')['delta_waa_allocation'].mean()['sindh'], color=colors['sindh'], linestyle='dashed')
ax1.axhline(y=0, color='black', alpha=1, linewidth=0.5, linestyle='dashed', label='Average')

ax1.set_ylim(-0.4,0.05)
ax1.yaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax1.legend(loc=3, ncol=1)
ax1.set_title(r"$\bf{Figure}$ $\bf{2}$" "\n" r"$\it{WAA}$ $\it{Allocation}$ $\it{Delta}$ $\it{1992-2019}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (BoS Punjab, 1972-2020; BoS Sindh, 2021; ISRA, 1991)', (0,0), (0, -40), xycoords='axes fraction', textcoords='offset points', va='top')

plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig2_waa_allocation_1992_2019.png", bbox_inches="tight")

# Figure 3 Canal Withdrawals Time Series

df_water = df.pivot(values='canal_withdrawal_maf ', index="period_beginning_in", columns="province")

fig, ax1 = plt.subplots(figsize=(10,5))

ax1.plot(df_water, marker=".", label=['Punjab','Sindh'])
ax1.set_ylim([20,60])

ax1.lines[0].set_color(colors['punjab'])
ax1.lines[1].set_color(colors['sindh'])

ax1.hlines(y = [55.94,48.76], xmin=1991, xmax=2019, color = 'goldenrod', linestyle = 'solid', label='WAA Allocation', alpha=0.9)
ax1.axvline(x=1991, color='black', linestyle='dashed', alpha=0.4)

plt.rcParams['text.usetex'] = False
ax1.legend()
ax1.set_ylabel('Million Acre Feet')
ax1.annotate('WAA Start', xy=(1990,21), rotation=90.0)
ax1.annotate('Sindh', xy=(1992,49.1))
ax1.annotate('Punjab', xy=(1992,56.1))
ax1.set_title(r"$\bf{Figure}$ $\bf{3}$" "\n" r"$\it{Canal}$ $\it{Withdrawals}$ $\it{1970-2019}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (BoS Punjab, 1972-2020; BoS Sindh, 2021)', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig3_canal_withdrawals_1970_2019.png", bbox_inches="tight")

# Figure 4 Indus Inflow

df_inflow = pd.read_csv('/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/total_water_flow_1987_2018.csv', index_col='period_beginning_in')

fig, ax1 = plt.subplots(figsize=(10,5))

df_inflow.plot(ax=ax1, marker='.', title='Indus River System Inflow', color='slategrey', legend=False, alpha=0.5)
ax1 = sns.regplot(x=df_inflow.index, y=df_inflow[' total_river_fow_maf '], ci=None, scatter=False, color='slategrey', line_kws={'linewidth':2, 'linestyle':'dashed'})
ax1.set_xlabel('')
ax1.set_ylabel('Million Acre Feet')
ax1.set_ylim(80,180)
ax1.set_title(r"$\bf{Figure}$ $\bf{4}$" "\n" r"$\it{Indus}$ $\it{River}$ $\it{Inflow}$ $\it{1987-2018}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (BoS Pakistan, [2004,2010,2015,2020])', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')


plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig4_indus_river_inflow_1987_2018.png", bbox_inches="tight")

# Figure 5 Tubewell Growth

df_tubewell = df.loc[df["period_beginning_in"] >= 1965].pivot(values='tubewells',index='period_beginning_in',columns='province')

fig, ax1 = plt.subplots(figsize=(10,5))

df_tubewell.plot(kind='line', ax=ax1, xlabel= '', color=colors, marker='.')
plt.annotate(xy=(1985.5,30000), xytext=(1985.5,110000), text="Data Unavailable", fontsize=8,
             arrowprops=dict(arrowstyle='-[, widthB=6, lengthB=0.5', facecolor='black'),
            horizontalalignment='center',
             verticalalignment='top')
ax1.yaxis.set_major_formatter(million_formatter)

ax1.set_title(r"$\bf{Figure}$ $\bf{5}$" "\n" r"$\it{Tubewell}$ $\it{Growth}$ $\it{1965-2019}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (BoS Punjab, 1971-2020; BoS Sindh 2009-2021; World Bank, 1984)', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig5_tubewell_growth_1965_2019.png", bbox_inches="tight")

# Figure 6 Sindh Tubewell YoY

df_delta_tubewell = df_tubewell.loc[df_tubewell.index >= 1965,["punjab","sindh"]]

df_delta_tubewell["change Punjab"] = df_delta_tubewell["punjab"] / df_delta_tubewell["punjab"].shift(1) - 1
df_delta_tubewell["change Sindh"] = df_delta_tubewell["sindh"] / df_delta_tubewell["sindh"].shift(1) - 1

fig, ax = plt.subplots(figsize=(10,5))

ax2 = ax.twinx()

df_delta_tubewell[["change Sindh"]].plot(ax=ax, 
                                         color=(colors["sindh"]), 
                                         marker=".", 
                                         xlabel="",
                                         legend=False)

df_waa_delta["sindh"].plot(kind='line', ax=ax2, color='navy', xlabel='', rot=45, marker='.', alpha=0.3)

lines, labels = ax.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax2.legend(lines + lines2, ["YoY Tubewell Growth (Left)", "WAA Deficit (Right)"], loc=2)

ax.yaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax2.yaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax.set_title(r"$\bf{Figure}$ $\bf{6}$" "\n" r"$\it{Sindh}$ $\it{Tubewell}$ $\it{Growth}$ $\it{1965-2019}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (BoS Sindh 2009-2021; World Bank, 1984; BoS Pakistan, [2004,2010,2015,2020])', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig6_yoy_tubewell_growth_1965_2018.png", bbox_inches="tight")

# Figure 7 Cropland Size and Fertilizer Growth

fig, ax1 = plt.subplots(figsize=(10,5))

ax2 = ax1.twinx()
ax1.plot(df.loc[df["period_beginning_in"] > 1990]\
         .pivot(values="ttl_cropped_area_mha", index="period_beginning_in", columns="province"), 
         marker=".",
        label=['Cropped Area (Punjab)','Cropped Area (Sindh)'])
ax2.plot(df.loc[df["period_beginning_in"] > 1990]\
         .pivot(values="sale_fertilizer_ttonnes", index="period_beginning_in", columns="province"), 
         linestyle="dashed", 
         marker=".", 
         alpha=0.6, 
         dash_joinstyle="bevel",
        label=['Fertilizer (Punjab)','Fertilizer (Sindh)'])

ax1.set_ylim([0,25])
ax2.set_ylim([0,4000])

ax1.lines[0].set_color(colors["punjab"])
ax1.lines[1].set_color(colors["sindh"])
ax2.lines[0].set_color(colors["punjab"])
ax2.lines[1].set_color(colors["sindh"])

lns = ax1.lines+ax2.lines
labs = [l.get_label() for l in lns]
ax1.legend(lns, labs, loc=2, ncol=2)

ax1.set_ylabel('Total Cropped Area (Mha)')
ax2.set_ylabel('Fertilizer Sales (000 Tonnes)')
ax1.set_title(r"$\bf{Figure}$ $\bf{7}$" "\n" r"$\it{Cropland}$ $\it{and}$ $\it{Fertilzier}$ $\it{Growth}$ $\it{1965-2019}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (BoS Punjab, 1971-2020; BoS Sindh 2021)', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig7_croland_fertilizer_growth_1990_2019.png", bbox_inches="tight")

# Figure 8 World Comparison

dffao = pd.read_csv("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/fao_fertilizer_usage_hectare_hist.csv", index_col="Year")

fig, ax1 = plt.subplots(figsize=(10,5))

pd.merge(dfh2.pivot(index="period_beginning_in", columns="province", values="fe_per_hectare"),dffao, left_index=True, right_index=True)\
    .plot(ax=ax1, marker=".", xlabel="", ylabel="Fertilizer " r"($kgha^{-1}$)", color=(colors['punjab'],colors['sindh'],'cadetblue','lightblue','lightskyblue'))

ax1.legend(ncol=2)
ax1.set_title(r"$\bf{Figure}$ $\bf{8}$" "\n" r"$\it{Fertilizer}$ $\it{Concentration}$ $\it{1992-2019}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (BoS Punjab, 1971-2020; BoS Sindh 2021; FAO, 2020)', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig8_cropland_fertilizer_world_comparison.png", bbox_inches="tight")

# Figure 9 Fertilizer Concentration Trend

df_fpp = df.loc[df["period_beginning_in"] > 1990].pivot(values="fe_consum_per_ttl_cropped_mha", index="period_beginning_in", columns="province")

fig, ax1 = plt.subplots(figsize=(10,5))

ax1.plot(df_fpp, marker=".", alpha=0.6, label=['punjab','sindh'])
ax1 = sns.regplot(x=df_fpp.index, y=df_fpp['punjab'], ci=None, color=colors['punjab'], scatter=False, line_kws={'linewidth':2, 'linestyle':'dashed'})
ax1 = sns.regplot(x=df_fpp.index, y=df_fpp['sindh'], ci=None, color=colors['sindh'], scatter=False, line_kws={'linewidth':2, 'linestyle':'dashed'})

ax1.lines[0].set_color(colors['punjab'])
ax1.lines[1].set_color(colors['sindh'])

ax1.set_ylabel("Fertilizer " r"($kgha^{-1}$)")
ax1.set_xlabel(None)
ax1.legend()
ax1.set_title(r"$\bf{Figure}$ $\bf{9}$" "\n" r"$\it{Fertilizer}$ $\it{Concentration}$ $\it{Trend}$ $\it{1990-2019}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (BoS Punjab, 1971-2020; BoS Sindh 2021)', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig9_fertilizer_per_tha_usage_1990_2019.png", bbox_inches="tight")

# Figure 10 Crop Output Timeseries

fig, ax = plt.subplots(figsize=(10,5))

df_agri.loc[df_agri["Province"].isin(["punjab","sindh"])].pivot(values="All Crops", index="Period", columns="Province")\
    .plot(ax=ax, color=colors, xlabel="", ylabel="(000) Ton")

ax.set_title(r"$\bf{Figure}$ $\bf{10}$" "\n" r"$\it{Crop}$ $\it{Production}$ $\it{1960-2021}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (AMIS, 2023)', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

ax.legend(ncol=2)

plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig10_agri_growth_1960_2021.png", bbox_inches="tight")

# Figure 11 Fertilizer Intensity

dfh2 = pd.read_csv("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/combined_province_1964_2019_r.csv")
dfh2 = dfh2.loc[dfh2["period_beginning_in"] >= 1992,["period_beginning_in","province","sale_fertilizer_kg","total_cropped_area_km2","total_crop_production_kg"]]

dfh2["fe_prod_kg"] = dfh2["sale_fertilizer_kg"] / dfh2["total_crop_production_kg"]

df_f_crop = dfh2.pivot(index="period_beginning_in", columns="province", values="fe_prod_kg")

fig, ax = plt.subplots(figsize=(10,5))

df_f_crop.plot(ax=ax, color=colors, marker=".", alpha=0.6)

ax = sns.regplot(x=df_f_crop.index, y=df_f_crop['punjab'], ci=None, color=colors['punjab'], scatter=False, line_kws={'linewidth':2, 'linestyle':'dashed'})
ax = sns.regplot(x=df_f_crop.index, y=df_f_crop['sindh'], ci=None, color=colors['sindh'], scatter=False, line_kws={'linewidth':2, 'linestyle':'dashed'})

ax.set_ylabel("Fertilizer " r"($kgkg^{-1}$)")
ax.set_xlabel("")

ax.set_title(r"$\bf{Figure}$ $\bf{11}$" "\n" r"$\it{Fertilizer}$ $\it{Intensity}$ $\it{1992-2019}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (BoS Punjab, 1971-2020; BoS Sindh 2021)', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

ax.legend(ncol=2)

plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig11_crop_fertilizer_productivity_hist.png", bbox_inches="tight")

# Figure 13 Maximum Inundation

df = pd.read_csv("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/h3_data_final.csv", index_col="district")

df.rename(columns={"2020_max_inundation_pct" : "2022 Inundation Pct"}, inplace=True)
df["is_left_bank"] = np.where(np.isin(df["division"],['Larkana','Hyderabad']),1,0)
df["fertilizer 5yr kg"] = df["fertilizer_5yr_avg"] * 1000
df["fertilizer intensity 5yr"] = (df["fertilizer 5yr kg"] / df["Total Cropped Area (Hectare) 5y"])

fig, ax1 = plt.subplots(figsize=(5,7))

df[["is_left_bank","division","2022 Inundation Pct","2010_max_inundation_pct"]]\
    .reset_index()\
    .set_index(["is_left_bank","division","district"])\
    .sort_values(by=["is_left_bank","division","2022 Inundation Pct"], axis=0).plot(kind="barh", ax=ax1, xlabel="", xlim=(0,1), colormap="tab20b")

ax1.set_yticklabels(df.sort_values(by=["is_left_bank","division","2022 Inundation Pct"], axis=0).index.values)
ax1.xaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax1.annotate(xy=(0.75,13), text="Right", fontsize=20)
ax1.annotate(xy=(0.75,3), text="Left", fontsize=20)
ax1.legend(labels=["2022 Inundation","2010 Inundation"])
ax1.hlines(y=10.5, xmin=0, xmax=1, color="slategrey", alpha=0.8)
ax1.set_title(r"$\bf{Figure}$ $\bf{13}$" "\n" r"$\it{2022}$ $\it{Maximum}$ $\it{Inundation}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (SUPARCO, 2023)', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig13_inundation_2022_district_left.png", bbox_inches="tight")

# Figure 14 / 15 Destroyed Cropland & Production

df["Damaged"] = (df["Net Area Sown (Hectare) 5y"] * df["pct_destroyed_cropland"]) / 1000
df["Undamaged"] = (df["Net Area Sown (Hectare) 5y"] - df["Damaged Crop Land"]) / 1000

fig, ax1 = plt.subplots(ncols=2, figsize=(10,3))

df.loc[:,["Damaged","Undamaged"]].plot(kind="bar", stacked=True, xlabel="", ylabel="Hectare (000)", colormap="tab20c", ax=ax1[0])
df.loc[:,["prod_all_grains_mton","prod_all_fruits_mton","prod_all_veg_mton"]].plot(kind="bar", xlabel="", ylabel="Metric Ton", stacked=True, colormap="tab20b", ax=ax1[1])
ax1[1].legend(labels=["Grain","Fruits","Vegetable"], ncol=2)
ax1[0].legend(ncol=2)

ax1[0].set_title(r"$\bf{Figure}$ $\bf{14}$" "\n" r"$\it{Crop}$ $\it{Area}$ $\it{Destroyed}$", loc='left')
ax1[1].set_title(r"$\bf{Figure}$ $\bf{15}$" "\n" r"$\it{Crop}$ $\it{Production}$ $\it{2019}$", loc='left')
ax1[1].yaxis.set_major_formatter(million_formatter)
ax1[0].annotate(r"$\it{Note.}$" 'Source: (PDMA, 2023b)', (0,0), (0, -120), xycoords='axes fraction', textcoords='offset points', va='top')
ax1[1].annotate(r"$\it{Note.}$" 'Source: (BoS Sindh, 2009-2020)', (0,0), (0, -120), xycoords='axes fraction', textcoords='offset points', va='top')
plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig14_fig15_crop destruction and production 2019.png", bbox_inches="tight")

# Figure 16 Fertilizer Concentration

fig, ax1 = plt.subplots(figsize=(5,7))

df[["fertilizer intensity 5yr"]]\
.plot(kind="barh", ax=ax1, xlabel="", colormap="Dark2", legend=False)

ax1.set_title(r"$\bf{Figure}$ $\bf{16}$" "\n" r"$\it{Fertilizer}$ $\it{Concentration}$ $\it{kgha^{-1}}$", loc='left')
ax1.annotate(r"$\it{Note.}$" 'Source: (BoS Sindh, 2009-2020)', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')
plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig16_fertilizer_concentration_sindh.png", bbox_inches="tight")

# Figure 17 Correlation Inundation

fig = plt.figure(figsize=(4, 4))

corr_cols = ["2022 Inundation Pct",
    "2010_max_inundation_pct",
    "fertilizer intensity 5yr"]
corr_ticks = []

for i in range(0,len(corr_cols)):
    corr_ticks.append(i)

ax = plt.matshow(df[corr_cols].corr(), fignum=fig.number, cmap='PiYG')
fig.colorbar(ax,fraction=0.046, pad=0.04)

plt.xticks(ticks=corr_ticks, labels=corr_cols, rotation=45, fontsize=8, ha='left')
plt.yticks(ticks=corr_ticks, labels=corr_cols, fontsize=8)
plt.title(r"$\bf{Figure}$ $\bf{17}$" "\n" r"$\it{Correlation}$ $\it{Matrix}$ $\it{Inundation}$ $\it{Fertilizer}$", loc='left')
plt.annotate(r"$\it{Note.}$" 'Source: (SUPARCO, 2023; BoS Sindh, 2009-2020)', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

plt.savefig("/Users/josepherlanger/Hertie/Pakistan Reading Material/datasets/figures/fig17_inundation_fertilizer_corr.png", bbox_inches="tight")