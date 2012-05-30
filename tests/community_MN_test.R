# Functions requiring M and/or N
TestBodyMassBins <- function()
{
    stopifnot(all(c(1,3,10)==BodyMassBins(c6)))
    stopifnot(all(c(1,1,3)==BodyMassBins(c6, n.bins=3)))
    stopifnot(all(c(2,2,2,1,2,1,1,5,2,2,1,1,2,3,2,3,3,2,2,1,4,3,2,3,1,2,1,2,3,
                    4,1,4,5,5,3,6,5,6,4,4,4,7,3,3,3,6,6,4,4,4,4,6,7,10,10,10)==
                  BodyMassBins(TL84)))

    F(BodyMassBins(c1))
    F(BodyMassBins(c2))
    F(BodyMassBins(TL84, n.bins=1))
    F(BodyMassBins(TL84, upper=min(NP(TL84,'M')), lower=max(NP(TL84,'M'))))
    F(BodyMassBins(TL84, lower=mean(NP(TL84,'M')), upper=max(NP(TL84,'M'))))
    F(BodyMassBins(TL84, lower=min(NP(TL84,'M')), upper=mean(NP(TL84,'M'))))
}

TestResourceLargerThanConsumer <- function()
{
    stopifnot(is.null(ResourceLargerThanConsumer(c1)))
    stopifnot(is.null(ResourceLargerThanConsumer(c2)))
    stopifnot(0==nrow(ResourceLargerThanConsumer(c6)))
    check <- ResourceLargerThanConsumer(TL84)
    stopifnot(all(c('Cyclops varians rubellus', 'Leptodiaptomus siciloides')==
                  check$resource))
    stopifnot(all(c('Tropocyclops prasinus', 'Tropocyclops prasinus')==
                  check$consumer))

}

TestSumNByClass <- function()
{
    F(SumNByClass(c1))
    F(SumNByClass(c2))
    stopifnot(all(NP(c6,'N') == 
                  SumNByClass(c6, class=c('a','b','c'))))
    stopifnot(all(sum(NP(c6,'N')) == 
                  SumNByClass(c6, class=c('a','a','a'))))
    stopifnot(all(sum(NP(c6,'N')[1:2]) == 
                  SumNByClass(c6, class=c('a','a',NA))))
    stopifnot(all(c(NP(c6,'N')[3], sum(NP(c6,'N')[1:2])) == 
                  SumNByClass(c6, class=c('a','a',''))))

    res <- SumNByClass(TL84)
    stopifnot(all(c(1.8678e+06, 3.2107e+09, 2.2350e+00) == res))
    stopifnot(c('invertebrate', 'producer', 'vert.ecto') == names(res))

    F(SumNByClass(c6, class=NULL))
}

TestSumBiomassByClass <- function()
{
    F(SumNByClass(c1))
    F(SumNByClass(c2))
    stopifnot(all(Biomass(c6) == 
                  SumBiomassByClass(c6, class=c('a','b','c'))))
    stopifnot(all(sum(Biomass(c6)) == 
                  SumBiomassByClass(c6, class=c('a','a','a'))))
    stopifnot(all(sum(Biomass(c6)[1:2]) == 
                  SumBiomassByClass(c6, class=c('a','a',NA))))
    stopifnot(all(c(Biomass(c6)[3], sum(Biomass(c6)[1:2])) == 
                  SumBiomassByClass(c6, class=c('a','a',''))))

    res <- SumBiomassByClass(TL84)
    stopifnot(all.equal(c(0.005376146,0.007438267,0.002315590), as.vector(res), 
                        tolerance=1e-7))
    stopifnot(c('invertebrate', 'producer', 'vert.ecto') == names(res))

    F(SumBiomassByClass(c6, class=NULL))
}

TestNvMLinearRegressions <- function()
{
    stopifnot(is.null(NvMLinearRegressions(c1)))
    stopifnot(is.null(NvMLinearRegressions(c2)))

    # Using default class of category - all NA as c6 does not have category
    res <- NvMLinearRegressions(c6)
    stopifnot('all'==names(res))
    stopifnot(all(c(2.58,-1.04) == round(coef(res[['all']]), 2)))

    # class==NULL should result in a single lm object being returned
    res <- NvMLinearRegressions(c6, class=NULL)
    stopifnot('all'==names(res))
    stopifnot(all(c(2.58,-1.04) == round(coef(res[['all']]), 2)))

    # Each node is in it's own class. Can't fit lm through one data point 
    # so should only have 'all'
    res <- NvMLinearRegressions(c6, class=c(1,2,3))
    stopifnot('all'==names(res))
    stopifnot(all(c(2.58,-1.04) == round(coef(res[['all']]), 2)))

    # Node 1 in a different class to nodes 2 and 3
    res <- NvMLinearRegressions(c6, class=c(1,2,2))
    stopifnot(c('all','2')==names(res))
    stopifnot(all(c(2.58,-1.04) ==  round(coef(res[['all']]), 2)))
    stopifnot(all(c(1.14,-0.20) ==  round(coef(res[['2']]), 2)))

    # category is default class
    res <- NvMLinearRegressions(TL84)
    stopifnot(all(c('all', 'producer', 'invertebrate', 'vert.ecto') == 
                  names(res)))
    stopifnot(all(c(-2.69, -0.83) == round(coef(res[['all']]), 2)))
    stopifnot(all(c(2.56, -0.41) == round(coef(res[['producer']]), 2)))
    stopifnot(all(c(1.47, -0.32) == round(coef(res[['invertebrate']]), 2)))
    stopifnot(all(c(-34.66, -11.63) == round(coef(res[['vert.ecto']]), 2)))
}

TestNvMTriTrophic1 <- function()
{
    # Recreates Table 1 from Cohen et al 2010 PNAS
    # NvMTriTrophicStatistics() removes both nodes with M and/or N of NA 
    # and cannibalistic links. I am removing these here too so that the 
    # network statistics (L, S^2, L/S^2 and L/S) are the same as those in 
    # Cohen et al 2010 PNAS, Table 1.
    communities <- list(TL84, TL86, RemoveNodes(YthanEstuary, 'POM (detritus)'))
    communities <- lapply(communities, RemoveCannibalisticLinks)
    communities <- lapply(communities, RemoveIsolatedNodes)

    # Table 1
    res <- NULL
    for(community in communities)
    {
        if(TRUE)
        {
            # The newer way
            tts <- NvMTriTrophicStatistics(community)
            lp <- tts[['links']]
            tncp <- tts[['three.node.chains']]
            tcp <- tts[['trophic.chains']]
        }
        else
        {
            # The older way
            lp <- NvMTrophicLinkProperties(community)
            tncp <- NvMTriTrophicChainProperties(community)
            tcp <- NvMTrophicChainsProperties(community)
        }

        community.span <- diff(range(Log10M(community))) + 
                          diff(range(Log10N(community)))

        wiggling <- mean(tcp[,'sum.chain.length']) / mean(tcp[,'chain.span'])

        res <- cbind(res, rbind(
         mean(lp[,'length']), 
         mean(tncp[,'Lupper']),
         mean(tncp[,'Llower']),
         2*mean(lp[,'length']), 
         mean(tncp[,'two.span']), 
         mean(tncp[,'Lupper']+tncp[,'Llower']),
         2 * mean(lp[,'length']) / mean(tncp[,'two.span']), 
         mean(tncp[,'Lupper'] + tncp[,'Llower']) / mean(tncp[,'two.span']), 
         mean(tcp[,'count.chain.length']),
         mean(tcp[,'count.chain.length'])*mean(lp[,'length']), 
         community.span,
         mean(tcp[,'count.chain.length'])*mean(lp[,'length'])/community.span,
         mean(tcp[,'sum.chain.length']),
         mean(tcp[,'chain.span']),
         mean(tcp[,'chain.span']) / community.span,
         mean(tcp[,'sum.chain.length']) / mean(tcp[,'chain.span']),
         mean(tcp[,'sum.chain.length']) / community.span,
         NumberOfTrophicLinks(community),
         NumberOfNodes(community)^2,
         DirectedConnectance(community),
         NumberOfTrophicLinks(community)/NumberOfNodes(community)))
    }

    colnames(res) <- c('TL84', 'TL86', 'Ythan Estuary')
    rownames(res) <- c('Mean link length', 
               'Mean L upper',
               'Mean L lower',
               '2 x mean link length',
               'Mean 2-span',
               'Mean L upper + L lower',
               '2 x mean link length / mean 2-span',
               'Mean L upper + L lower / mean 2-span',
               'Mean count chain length',
               'Mean count chain length x mean link length',
               'Community span',
               'Mean count chain length x mean link length / community span',
               'Mean sum chain lengths',
               'Mean chain span',
               'Mean chain span / community span',
               'Mean sum chain lengths / mean chain span',
               'Mean sum chain lengths / community span',
               'L',
               'S^2',
               'L/S^2',
               'L/S')

    # The data from the paper
    check <- matrix(c(
               6.33,    5.90,    7.29, 
               5.41,    3.43,    5.06, 
               5.99,    5.69,    6.15, 
              12.67,   11.79,   14.57, 
              11.02,    8.65,   10.51, 
              11.40,    9.12,   11.20, 
               1.15,    1.36,    1.39, 
               1.03,    1.05,    1.07, 
               4.84,    4.84,    4.43, 
              30.62,   28.56,   32.31, 
              20.78,   22.66,   21.98, 
               1.47,    1.26,    1.47, 
              19.96,   23.33,   16.88, 
              18.71,   20.63,   13.18,  # TL86 mean chain span 20.63 vs 20.62
               0.90,    0.91,    0.60, 
               1.07,    1.13,    1.28, 
               0.96,    1.03,    0.77, 
             264.00,  236.00,  379.00, 
            2500.00, 2601.00, 8281.00, 
               0.11,    0.09,    0.05, 
               5.28,    4.63,    4.16), ncol=3, byrow=TRUE)

    colnames(check) <- colnames(res)
    rownames(check) <- rownames(res)
    stopifnot(all.equal(round(res, 2), check))
}

TestNvMTriTrophic2 <- function()
{
    # Recreates Table S3 from Cohen et al 2010 PNAS
    data(TL84)
    data(TL86)
    data(YthanEstuary)

    communities <- list(TL84, TL86, RemoveNodes(YthanEstuary,'POM (detritus)'))
    communities <- lapply(communities, RemoveIsolatedNodes)
    communities <- lapply(communities, RemoveCannibalisticLinks)

    res <- NULL
    for(community in communities)
    {
        chains <- ThreeNodeChains(community, node.properties='M')
        MR <- chains[,'bottom.M']
        MI <- chains[,'intermediate.M']
        MC <- chains[,'top.M']

        col <- rbind(sum(MR<=MI & MI<=MC), 
                     sum(MR<=MC & MC<MI), 
                     sum(MI<MR  & MR<=MC), 
                     sum(MI<=MC & MC<MR), 
                     sum(MC<MR  & MR<MI), 
                     sum(MC<MI  & MI<MR), 
                     nrow(chains))

        lp <- TLPS(community, node.properties='M')
        MR <- lp[,'resource.M']
        MC <- lp[,'consumer.M']
        col <- rbind(col, 
                     sum(MR<MC), 
                     sum(MR==MC), 
                     sum(MR>MC), 
                     nrow(lp))

        res <- cbind(res, col)
    }

    colnames(res) <- c('TL84', 'TL86', 'Ythan Estuary')
    rownames(res) <- c('MR<=MI<=MC', 
                       'MR<=MC<MI', 
                       'MI<MR<=MC', 
                       'MI<=MC<MR', 
                       'MC<MR<MI', 
                       'MC<MI<MR', 
                       'All 2-chains', 
                       'MR<MC', 
                       'MR=MC', 
                       'MR>MC',
                       'All links')

    # The data from the paper
    check <- matrix(c(  1001,  577,  1232,
                          30,   59,    65,
                          12,   10,    68,
                           0,    1,     3,
                           1,    3,     0,
                           0,    1,     3,
                        1044,  651,  1371,
                         262,  232,   368,
                           0,    0,     2,
                           2,    4,     9,
                         264,  236,   379), ncol=3, byrow=TRUE)

    colnames(check) <- colnames(res)
    rownames(check) <- rownames(res)
    stopifnot(all.equal(round(res, 2), check))
}

TestNodesWithoutMOrN <- function()
{
    NodesWithoutMOrN <- cheddar:::.NodesWithoutMOrN
    stopifnot('S'==NodesWithoutMOrN(c1))
    stopifnot('S'==NodesWithoutMOrN(c2))
    stopifnot(all(c('R','C')==NodesWithoutMOrN(c3)))
    stopifnot(all(c('R','C','P')==NodesWithoutMOrN(c4)))
    stopifnot(all(c('R','C','O')==NodesWithoutMOrN(c5)))
    stopifnot(0==length(NodesWithoutMOrN(c6)))
    stopifnot(0==length(NodesWithoutMOrN(TL84)))
    stopifnot('POM (detritus)'==NodesWithoutMOrN(YthanEstuary))
}

TestNvMSlopeAndIntercept <- function()
{
    stopifnot(is.null(NvMSlope(c1)))
    stopifnot(is.null(NvMSlope(c2)))
    stopifnot(is.null(NvMSlope(c3)))
    stopifnot(is.null(NvMSlope(c4)))
    stopifnot(is.null(NvMSlope(c5)))
    stopifnot(all.equal(NvMSlope(c6), -1.04009302605305009592))
    stopifnot(all.equal(NvMSlope(TL84), -0.82711453844476423569))

    stopifnot(is.null(NvMIntercept(c1)))
    stopifnot(is.null(NvMIntercept(c2)))
    stopifnot(is.null(NvMIntercept(c3)))
    stopifnot(is.null(NvMIntercept(c4)))
    stopifnot(is.null(NvMIntercept(c5)))
    stopifnot(all.equal(NvMIntercept(c6), 2.57689795300774049380))
    stopifnot(all.equal(NvMIntercept(TL84), -2.68627529180856106095))

    stopifnot(is.null(NvMSlopeAndIntercept(c1)))
    stopifnot(is.null(NvMSlopeAndIntercept(c2)))
    stopifnot(is.null(NvMSlopeAndIntercept(c3)))
    stopifnot(is.null(NvMSlopeAndIntercept(c4)))
    stopifnot(is.null(NvMSlopeAndIntercept(c5)))
    stopifnot(all.equal(NvMSlopeAndIntercept(c6), 
                        c(slope=-1.04009302605305009592, 
                          intercept=2.57689795300774049380)))    
    stopifnot(all.equal(NvMSlopeAndIntercept(TL84), 
                        c(slope=-0.82711453844476423569, 
                          intercept=-2.68627529180856106095)))
}

TestNvMSlopeAndInterceptByClass <- function()
{
    stopifnot(all.equal(NvMSlopeByClass(c6), c(slope.=-1.04009302605305009592)))
    stopifnot(all.equal(NvMSlopeByClass(TL84), 
                        c(slope.all=-0.82711453844476423569, 
                          slope.producer=-0.40715089579609509141, 
                          slope.invertebrate=-0.32431675051076519489, 
                          slope.vert.ecto=-11.62787086769622924010)))

    stopifnot(all.equal(NvMInterceptByClass(c6), 
                        c(intercept.=2.57689795300774049380)))
    stopifnot(all.equal(NvMInterceptByClass(TL84), 
                        c(intercept.all=-2.68627529180856106095, 
                          intercept.producer=2.55833642234355362888, 
                          intercept.invertebrate=1.46560619016986248830, 
                          intercept.vert.ecto=-34.66097278952445748246)))

    stopifnot(all.equal(NvMSlopeAndInterceptByClass(c6), 
                        c(slope.=-1.04009302605305009592, 
                          intercept.=2.57689795300774049380)))
    stopifnot(all.equal(NvMSlopeAndInterceptByClass(TL84), 
                        c(slope.all=-0.82711453844476423569, 
                          slope.producer=-0.40715089579609509141, 
                          slope.invertebrate=-0.32431675051076519489, 
                          slope.vert.ecto=-11.62787086769622924010, 
                          intercept.all=-2.68627529180856106095, 
                          intercept.producer=2.55833642234355362888, 
                          intercept.invertebrate=1.46560619016986248830, 
                          intercept.vert.ecto=-34.66097278952445748246)))
}
