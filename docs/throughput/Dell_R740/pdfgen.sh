#!/bin/bash
#---------------------------------------------------------------------------
# File: pdfgen.sh
# Created Date: 2021-08-23
# Author: ZhangDanfeng
# Contact: <zhangdanfeng@cloudwalk.com>
# 
# Last Modified: Monday August 23rd 2021 4:34:37 pm
# 
# Copyright (c) 2021 CloudWalk Technology Co., Ltd..
# This File Is Part Of Cloudwalk Feature Clustering Similarity Calculs.
# -----
# HISTORY:
# Date      By      Comments
# -------------------------------------------------------------------------
#---------------------------------------------------------------------------
pandoc X86_64.md -o X86_64.pdf --pdf-engine=xelatex -V CJKmainfont="Noto Sans CJK JP" --template=template.latex -V geometry:"top=2cm, bottom=1.5cm, left=2cm, right=2cm"
