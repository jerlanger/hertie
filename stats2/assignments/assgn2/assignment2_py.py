import pandas as pd
import numpy as np
import researchpy as rp
import math


def t_test(data, x, y):
    if df.dtypes[x] != object:
        out = rp.ttest(group1=data.loc[:, x][data.loc[:, y] == 1],
                       group1_name="treated",
                       group2=data.loc[:, x][data.loc[:, y] == 0],
                       group2_name="control")

        out = out[0].iloc[[0, 1]].iloc[:, [2]] \
            .transpose() \
            .rename({0: "treated", 1: "control"}, axis=1) \
            .assign(delta=out[1].iloc[0, 1],
                    pval=out[1].iloc[3, 1],
                    var=x)
    else:
        out = pd.DataFrame({"treated": math.nan,
                            "control": math.nan,
                            "delta": math.nan,
                            "pval": math.nan,
                            "var": x}, index=[0])

    return (out)


df = pd.read_csv("../hertie/stats2/assignments/assgn2/local/social_cohesion.csv")

covariates = ["edu",
              "church",
              "income",
              "status1",
              "marital",
              "isis_abuse",
              "birth.year"]

# df_results = pd.DataFrame.from_dict(np.concatenate([t_test(df,i,"treated") for i in covariates]), orient="columns")

ttest_out = []
for i in covariates:
    ttest_out.append(t_test(df, i, "treated"))

df_results = pd.DataFrame(np.concatenate(ttest_out), columns=[*ttest_out[0]])
df_results.head()

allV = []
for i in [*df]:
    allV.append(t_test(df,i,"treated"))

df_allV = pd.DataFrame(np.concatenate(allV), columns = [*ttest_out[0]])
df_allV.head()