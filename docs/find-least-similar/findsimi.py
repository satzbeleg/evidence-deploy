import numba
from typing import List


@numba.jit(nopython=False)
def hammingsim_two(v1: List[bool], v2: List[bool], sz: int) -> float:
    """ Matching coefficient """
    return (v1 == v2).sum() / sz

