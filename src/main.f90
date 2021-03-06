program main
  use exec_conditions
  use time_util
  use print_util
  use compute_receiver_position
  implicit none

!   使用局所領域
!   +------------------------------------------------------------------------------------------------------------
!   ! TYPE(LENGTH)            !  name(size)
!   +------------------------------------------------------------------------------------------------------------
      INTEGER, PARAMETER      :: SATS = 5                    ! 使用する衛星数
      INTEGER                 :: PRN_list(MAX_EPOCH, SATS)   ! 使用する衛星のリスト
      DOUBLE PRECISION        :: sats_range(MAX_EPOCH, SATS) ! 各衛星の位置とrangeの配列
      DOUBLE PRECISION        :: pseudo_range(MAX_PRN)       ! 観測量
      DOUBLE PRECISION        :: sol(MAX_UNKNOWNS)           ! 方程式の解(位置ベクトル(x, y, z)とクロック誤差)
      INTEGER                 :: i, epoch_num                         ! ループ用カウンタ
      TYPE(wtime)             :: wt                          ! 測位計算に使用する観測エポック
      TYPE(wtime)             :: wt1                         ! 1エポック目
      TYPE(wtime)             :: wt2                         ! 2エポック目
      TYPE(wtime)             :: obs_epoch_list(MAX_EPOCH)   ! 観測エポックのリスト
      DOUBLE PRECISION        :: x, y, z, s                 ! 解の確認用(正しい解)
!   +-----------------------------------------------------------------------------------------------------------------

  ! 試験用実行条件

  ! 1 エポック目 ==========================
  ! 使用するPRN
  PRN_list(1, :) = (/ 5,14,16,22,25 /)

  ! 観測データを配列にセット
  sats_range(1, :) = (/ &
    23545777.534d0, & ! PRN 05
    20299789.570d0, & ! PRN 14
    24027782.537d0, & ! PRN 16
    24367716.061d0, & ! PRN 22
    22169926.127d0  & ! PRN 25
   /)

  ! 時刻を指定
  wt1%week = 1349     ! 05/11/13〜19の週
  wt1%sec = 86400.d0  ! 月曜日の00:00:00
  obs_epoch_list(1) = wt1
  ! =======================================

  ! 2 エポック目 ==========================
  ! 使用するPRN
  PRN_list(2, :) = (/ 5,14,16,22,25 /)

  ! 観測データを配列にセット
  sats_range(2, :) = (/ &
    23564241.845d0, & ! PRN 05
    20303872.469d0, & ! PRN 14
    24010342.238d0, & ! PRN 16
    24385805.243d0, & ! PRN 22
    22159442.572d0  & ! PRN 25
   /)

  ! 時刻を指定
  wt2%week = 1349     ! 05/11/13〜19の週
  wt2%sec = 86430.d0  ! 月曜日の00:00:30
  obs_epoch_list(2) = wt2

  ! =======================================


  ! 実行結果リスト作成，ヘッダ書き込み
  call make_list_file()

  ! Navigation Message File読み込み
  call read_nav_msg()

  ! Navigation Message ヘッダ部をリストに書き出し
  call print_nav_file_header()

  ! 擬似距離(観測データ)を初期化
  pseudo_range(:) = 0.d0

  ! 解を初期化
  sol(:) = 0.d0

  ! エポックごとのループ
  do epoch_num = 1, MAX_EPOCH
    print *,"Epoch Num", epoch_num
    ! 観測エポックをセット
    wt = obs_epoch_list(epoch_num)

    ! 擬似距離をセット
    do i=1, SATS
      pseudo_range(PRN_list(epoch_num, i)) = sats_range(epoch_num, i)
    end do

    ! 測位計算実行
    call main_calc_position(epoch_num, wt, pseudo_range, sol)


  end do

   ! 計算結果csvファイル初期化
  call print_csv_initialized()

  ! 計算csvファイル書き出し
  call print_correction_data()






  ! 正しい解
  x = -3947762.486d0
  y = 3364401.302d0
  z = 3699431.992d0
  s = -3.9032d-008
  write(6, *) "******************** 正しい計算結果 ******************************"
  write(6, '("x = ",f12.3,5X,"y = ",f12.3,5X,"z = ",f12.3, 5X,"s = ",d12.4)') x, y, z, s

end program main
