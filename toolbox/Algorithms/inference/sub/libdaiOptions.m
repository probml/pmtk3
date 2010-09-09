
% This file is from pmtk3.googlecode.com

% # This file contains reasonable default settings for various inference
% # algorithms in libDAI. Each non-empty line should either be a comment
% # (starting with #) or contain an alias definition in the format
% #
% # alias:    name[key1=val1,key2=val2,...,keyn=valn]
% #
% # where name should be a valid libDAI algorithm name, and the list of
% # its properties (between rectangular brackets) consists of key=value
% # pairs, seperated by spaces. This defines 'alias' as a shortcut for
% # the rest of the line (more precisely, the contents to the right of 
% # the colon and possible whitespace).
% 
% 
% # --- BP ----------------------
% 
% BP:                             BP[inference=SUMPROD,updates=SEQMAX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% 
% BP_SEQFIX:                      BP[inference=SUMPROD,updates=SEQFIX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% BP_SEQRND:                      BP[inference=SUMPROD,updates=SEQRND,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% BP_SEQMAX:                      BP[inference=SUMPROD,updates=SEQMAX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% BP_PARALL:                      BP[inference=SUMPROD,updates=PARALL,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% BP_SEQFIX_LOG:                  BP[inference=SUMPROD,updates=SEQFIX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% BP_SEQRND_LOG:                  BP[inference=SUMPROD,updates=SEQRND,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% BP_SEQMAX_LOG:                  BP[inference=SUMPROD,updates=SEQMAX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% BP_PARALL_LOG:                  BP[inference=SUMPROD,updates=PARALL,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% MP_SEQFIX:                      BP[inference=MAXPROD,updates=SEQFIX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% MP_SEQRND:                      BP[inference=MAXPROD,updates=SEQRND,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% MP_SEQMAX:                      BP[inference=MAXPROD,updates=SEQMAX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% MP_PARALL:                      BP[inference=MAXPROD,updates=PARALL,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% MP_SEQFIX_LOG:                  BP[inference=MAXPROD,updates=SEQFIX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% MP_SEQRND_LOG:                  BP[inference=MAXPROD,updates=SEQRND,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% MP_SEQMAX_LOG:                  BP[inference=MAXPROD,updates=SEQMAX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% MP_PARALL_LOG:                  BP[inference=MAXPROD,updates=PARALL,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% 
% # --- FBP ---------------------
% 
% FBP:                            FBP[inference=SUMPROD,updates=SEQMAX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% 
% FBP_SEQFIX:                     FBP[inference=SUMPROD,updates=SEQFIX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% FBP_SEQRND:                     FBP[inference=SUMPROD,updates=SEQRND,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% FBP_SEQMAX:                     FBP[inference=SUMPROD,updates=SEQMAX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% FBP_PARALL:                     FBP[inference=SUMPROD,updates=PARALL,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% FBP_SEQFIX_LOG:                 FBP[inference=SUMPROD,updates=SEQFIX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% FBP_SEQRND_LOG:                 FBP[inference=SUMPROD,updates=SEQRND,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% FBP_SEQMAX_LOG:                 FBP[inference=SUMPROD,updates=SEQMAX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% FBP_PARALL_LOG:                 FBP[inference=SUMPROD,updates=PARALL,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% FMP_SEQFIX:                     FBP[inference=MAXPROD,updates=SEQFIX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% FMP_SEQRND:                     FBP[inference=MAXPROD,updates=SEQRND,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% FMP_SEQMAX:                     FBP[inference=MAXPROD,updates=SEQMAX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% FMP_PARALL:                     FBP[inference=MAXPROD,updates=PARALL,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0]
% FMP_SEQFIX_LOG:                 FBP[inference=MAXPROD,updates=SEQFIX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% FMP_SEQRND_LOG:                 FBP[inference=MAXPROD,updates=SEQRND,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% FMP_SEQMAX_LOG:                 FBP[inference=MAXPROD,updates=SEQMAX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% FMP_PARALL_LOG:                 FBP[inference=MAXPROD,updates=PARALL,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0]
% 
% # --- TRWBP -------------------
% 
% TRWBP:                          TRWBP[updates=SEQFIX,tol=1e-9,maxiter=10000,logdomain=0,nrtrees=0]
% 
% TRWBP_SEQFIX:                   TRWBP[inference=SUMPROD,updates=SEQFIX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWBP_SEQRND:                   TRWBP[inference=SUMPROD,updates=SEQRND,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWBP_SEQMAX:                   TRWBP[inference=SUMPROD,updates=SEQMAX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWBP_PARALL:                   TRWBP[inference=SUMPROD,updates=PARALL,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWBP_SEQFIX_LOG:               TRWBP[inference=SUMPROD,updates=SEQFIX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWBP_SEQRND_LOG:               TRWBP[inference=SUMPROD,updates=SEQRND,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWBP_SEQMAX_LOG:               TRWBP[inference=SUMPROD,updates=SEQMAX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWBP_PARALL_LOG:               TRWBP[inference=SUMPROD,updates=PARALL,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWMP_SEQFIX:                   TRWBP[inference=MAXPROD,updates=SEQFIX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWMP_SEQRND:                   TRWBP[inference=MAXPROD,updates=SEQRND,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWMP_SEQMAX:                   TRWBP[inference=MAXPROD,updates=SEQMAX,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWMP_PARALL:                   TRWBP[inference=MAXPROD,updates=PARALL,logdomain=0,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWMP_SEQFIX_LOG:               TRWBP[inference=MAXPROD,updates=SEQFIX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWMP_SEQRND_LOG:               TRWBP[inference=MAXPROD,updates=SEQRND,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWMP_SEQMAX_LOG:               TRWBP[inference=MAXPROD,updates=SEQMAX,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% TRWMP_PARALL_LOG:               TRWBP[inference=MAXPROD,updates=PARALL,logdomain=1,tol=1e-9,maxiter=10000,damping=0.0,nrtrees=0]
% 
% # --- JTREE -------------------
% JTREE:                          JTREE[inference=SUMPROD,updates=HUGIN]
% JTREE_HUGIN:                    JTREE[inference=SUMPROD,updates=HUGIN]
% JTREE_SHSH:                     JTREE[inference=SUMPROD,updates=SHSH]
% 
% JTREE_MINFILL_HUGIN:            JTREE[inference=SUMPROD,heuristic=MINFILL,updates=HUGIN]
% JTREE_MINFILL_SHSH:             JTREE[inference=SUMPROD,heuristic=MINFILL,updates=SHSH]
% JTREE_MINFILL_HUGIN_MAP:        JTREE[inference=MAXPROD,heuristic=MINFILL,updates=HUGIN]
% JTREE_MINFILL_SHSH_MAP:         JTREE[inference=MAXPROD,heuristic=MINFILL,updates=SHSH]
% JTREE_WEIGHTEDMINFILL_HUGIN:    JTREE[inference=SUMPROD,heuristic=WEIGHTEDMINFILL,updates=HUGIN]
% JTREE_WEIGHTEDMINFILL_SHSH:     JTREE[inference=SUMPROD,heuristic=WEIGHTEDMINFILL,updates=SHSH]
% JTREE_WEIGHTEDMINFILL_HUGIN_MAP:JTREE[inference=MAXPROD,heuristic=WEIGHTEDMINFILL,updates=HUGIN]
% JTREE_WEIGHTEDMINFILL_SHSH_MAP: JTREE[inference=MAXPROD,heuristic=WEIGHTEDMINFILL,updates=SHSH]
% JTREE_MINWEIGHT_HUGIN:          JTREE[inference=SUMPROD,heuristic=MINWEIGHT,updates=HUGIN]
% JTREE_MINWEIGHT_SHSH:           JTREE[inference=SUMPROD,heuristic=MINWEIGHT,updates=SHSH]
% JTREE_MINWEIGHT_HUGIN_MAP:      JTREE[inference=MAXPROD,heuristic=MINWEIGHT,updates=HUGIN]
% JTREE_MINWEIGHT_SHSH_MAP:       JTREE[inference=MAXPROD,heuristic=MINWEIGHT,updates=SHSH]
% JTREE_MINNEIGHBORS_HUGIN:       JTREE[inference=SUMPROD,heuristic=MINNEIGHBORS,updates=HUGIN]
% JTREE_MINNEIGHBORS_SHSH:        JTREE[inference=SUMPROD,heuristic=MINNEIGHBORS,updates=SHSH]
% JTREE_MINNEIGHBORS_HUGIN_MAP:   JTREE[inference=MAXPROD,heuristic=MINNEIGHBORS,updates=HUGIN]
% JTREE_MINNEIGHBORS_SHSH_MAP:    JTREE[inference=MAXPROD,heuristic=MINNEIGHBORS,updates=SHSH]
% 
% # --- MF ----------------------
% 
% MF:                             MF[tol=1e-9,maxiter=10000,damping=0.0,init=UNIFORM,updates=NAIVE]
% 
% MF_NAIVE_UNI:                   MF[tol=1e-9,maxiter=10000,damping=0.0,init=UNIFORM,updates=NAIVE]
% MF_NAIVE_RND:                   MF[tol=1e-9,maxiter=10000,damping=0.0,init=RANDOM,updates=NAIVE]
% MF_HARDSPIN_UNI:                MF[tol=1e-9,maxiter=10000,damping=0.0,init=UNIFORM,updates=HARDSPIN]
% MF_HARDSPIN_RND:                MF[tol=1e-9,maxiter=10000,damping=0.0,init=RANDOM,updates=HARDSPIN]
% 
% # --- TREEEP ------------------
% 
% TREEEP:                         TREEEP[type=ORG,tol=1e-9,maxiter=10000]
% TREEEPWC:                       TREEEP[type=ALT,tol=1e-9,maxiter=10000]
% 
% # --- MR ----------------------
% 
% MR_DEFAULT:                     MR[updates=FULL,inits=RESPPROP,tol=1e-9]
% MR_RESPPROP_FULL:               MR[updates=FULL,inits=RESPPROP,tol=1e-9]
% MR_RESPPROP_LINEAR:             MR[updates=LINEAR,inits=RESPPROP,tol=1e-9]
% MR_CLAMPING_FULL:               MR[updates=FULL,inits=CLAMPING,tol=1e-9]
% MR_CLAMPING_LINEAR:             MR[updates=LINEAR,inits=CLAMPING,tol=1e-9]
% MR_EXACT_FULL:                  MR[updates=FULL,inits=EXACT,tol=1e-9]
% MR_EXACT_LINEAR:                MR[updates=LINEAR,inits=EXACT,tol=1e-9]
% 
% # --- HAK ---------------------
% 
% GBP_MIN:                        HAK[doubleloop=0,clusters=MIN,init=UNIFORM,tol=1e-9,maxiter=10000]
% GBP_BETHE:                      HAK[doubleloop=0,clusters=BETHE,init=UNIFORM,tol=1e-9,maxiter=10000]
% GBP_DELTA:                      HAK[doubleloop=0,clusters=DELTA,init=UNIFORM,tol=1e-9,maxiter=10000]
% GBP_LOOP3:                      HAK[doubleloop=0,clusters=LOOP,init=UNIFORM,loopdepth=3,tol=1e-9,maxiter=10000]
% GBP_LOOP4:                      HAK[doubleloop=0,clusters=LOOP,init=UNIFORM,loopdepth=4,tol=1e-9,maxiter=10000]
% GBP_LOOP5:                      HAK[doubleloop=0,clusters=LOOP,init=UNIFORM,loopdepth=5,tol=1e-9,maxiter=10000]
% GBP_LOOP6:                      HAK[doubleloop=0,clusters=LOOP,init=UNIFORM,loopdepth=6,tol=1e-9,maxiter=10000]
% GBP_LOOP7:                      HAK[doubleloop=0,clusters=LOOP,init=UNIFORM,loopdepth=7,tol=1e-9,maxiter=10000]
% GBP_LOOP8:                      HAK[doubleloop=0,clusters=LOOP,init=UNIFORM,loopdepth=8,tol=1e-9,maxiter=10000]
% 
% HAK_MIN:                        HAK[doubleloop=1,clusters=MIN,init=UNIFORM,tol=1e-9,maxiter=10000]
% HAK_BETHE:                      HAK[doubleloop=1,clusters=BETHE,init=UNIFORM,tol=1e-9,maxiter=10000]
% HAK_DELTA:                      HAK[doubleloop=1,clusters=DELTA,init=UNIFORM,tol=1e-9,maxiter=10000]
% HAK_LOOP3:                      HAK[doubleloop=1,clusters=LOOP,init=UNIFORM,loopdepth=3,tol=1e-9,maxiter=10000]
% HAK_LOOP4:                      HAK[doubleloop=1,clusters=LOOP,init=UNIFORM,loopdepth=4,tol=1e-9,maxiter=10000]
% HAK_LOOP5:                      HAK[doubleloop=1,clusters=LOOP,init=UNIFORM,loopdepth=5,tol=1e-9,maxiter=10000]
% HAK_LOOP6:                      HAK[doubleloop=1,clusters=LOOP,init=UNIFORM,loopdepth=6,tol=1e-9,maxiter=10000]
% HAK_LOOP7:                      HAK[doubleloop=1,clusters=LOOP,init=UNIFORM,loopdepth=7,tol=1e-9,maxiter=10000]
% HAK_LOOP8:                      HAK[doubleloop=1,clusters=LOOP,init=UNIFORM,loopdepth=8,tol=1e-9,maxiter=10000]
% 
% # --- LC ----------------------
% 
% LCBP_FULLCAVin_SEQFIX:          LC[cavity=FULL,reinit=1,updates=SEQFIX,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_FULLCAVin_SEQRND:          LC[cavity=FULL,reinit=1,updates=SEQRND,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_FULLCAVin_NONE:            LC[cavity=FULL,reinit=1,updates=SEQFIX,maxiter=0,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_FULLCAV_SEQFIX:            LC[cavity=FULL,reinit=0,updates=SEQFIX,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_FULLCAV_SEQRND:            LC[cavity=FULL,reinit=0,updates=SEQRND,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_FULLCAV_NONE:              LC[cavity=FULL,reinit=0,updates=SEQFIX,maxiter=0,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIRCAVin_SEQFIX:          LC[cavity=PAIR,reinit=1,updates=SEQFIX,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIRCAVin_SEQRND:          LC[cavity=PAIR,reinit=1,updates=SEQRND,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIRCAVin_NONE:            LC[cavity=PAIR,reinit=1,updates=SEQFIX,maxiter=0,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIRCAV_SEQFIX:            LC[cavity=PAIR,reinit=0,updates=SEQFIX,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIRCAV_SEQRND:            LC[cavity=PAIR,reinit=0,updates=SEQRND,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIRCAV_NONE:              LC[cavity=PAIR,reinit=0,updates=SEQFIX,maxiter=0,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIR2CAVin_SEQFIX:         LC[cavity=PAIR2,reinit=1,updates=SEQFIX,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIR2CAVin_SEQRND:         LC[cavity=PAIR2,reinit=1,updates=SEQRND,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIR2CAVin_NONE:           LC[cavity=PAIR2,reinit=1,updates=SEQFIX,maxiter=0,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIR2CAV_SEQFIX:           LC[cavity=PAIR2,reinit=0,updates=SEQFIX,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIR2CAV_SEQRND:           LC[cavity=PAIR2,reinit=0,updates=SEQRND,maxiter=10000,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_PAIR2CAV_NONE:             LC[cavity=PAIR2,reinit=0,updates=SEQFIX,maxiter=0,cavainame=BP,cavaiopts=[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0],tol=1e-9]
% LCBP_UNICAV_SEQFIX:             LC[cavity=UNIFORM,updates=SEQFIX,maxiter=10000,tol=1e-9,cavaiopts=[],cavainame=NONE]
% LCBP_UNICAV_SEQRND:             LC[cavity=UNIFORM,updates=SEQRND,maxiter=10000,tol=1e-9,cavaiopts=[],cavainame=NONE]
% 
% LCTREEEP:                       LC[cavity=FULL,reinit=1,updates=SEQFIX,maxiter=10000,cavainame=TREEEP,cavaiopts=[type=ORG,tol=1e-9,maxiter=10000],tol=1e-9]
% LCMF:                           LC[cavity=FULL,reinit=1,updates=SEQFIX,maxiter=10000,cavainame=MF,cavaiopts=[tol=1e-9,maxiter=10000],tol=1e-9]
% 
% 
% # --- GIBBS -------------------
% 
% GIBBS:                          GIBBS[iters=1000,burnin=100]
% GIBBS_1e1:                      GIBBS[iters=10,burnin=1]
% GIBBS_1e2:                      GIBBS[iters=100,burnin=10]
% GIBBS_1e3:                      GIBBS[iters=1000,burnin=100]
% GIBBS_1e4:                      GIBBS[iters=10000,burnin=1000]
% GIBBS_1e5:                      GIBBS[iters=100000,burnin=10000]
% GIBBS_1e6:                      GIBBS[iters=1000000,burnin=100000]
% GIBBS_1e7:                      GIBBS[iters=10000000,burnin=100000]
% GIBBS_1e8:                      GIBBS[iters=100000000,burnin=100000]
% GIBBS_1e9:                      GIBBS[iters=1000000000,burnin=100000]
% 
% # --- CBP ---------------------
% 
% CBP:                            CBP[max_levels=12,updates=SEQMAX,tol=1e-9,rec_tol=1e-9,maxiter=500,choose=CHOOSE_RANDOM,recursion=REC_FIXED,clamp=CLAMP_VAR,min_max_adj=1.0e-9,bbp_cfn=CFN_FACTOR_ENT,rand_seed=0,bbp_props=[tol=1.0e-9,maxiter=10000,damping=0,updates=SEQ_BP_REV],clamp_outfile=]
% BBP:                            CBP[choose=CHOOSE_BBP]
