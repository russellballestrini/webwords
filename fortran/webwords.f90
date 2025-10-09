program webwords
    ! Fortran WebWords Implementation
    ! Scientific-style string analysis using Fortran intrinsic functions
    implicit none
    
    ! Scientific analysis variables
    character(len=256) :: search_keyword
    character(len=65536) :: content_text
    character(len=256) :: keyword_upper, content_segment
    character(len=65536) :: content_upper
    logical :: keyword_found
    integer :: ios, keyword_unit, content_unit, result_unit
    
    ! Statistical analysis variables
    integer :: keyword_length, content_length, total_chars
    integer :: match_count, char_position, search_start
    integer :: total_words, total_lines, keyword_positions(100)
    real :: match_density, average_position, standard_deviation
    real :: position_variance, sum_positions, sum_squares
    
    ! Initialize scientific analysis
    call initialize_analysis()
    
    ! Read input data using Fortran I/O
    call read_keyword_data()
    call read_content_data()
    
    ! Perform scientific string analysis
    call perform_string_analysis()
    
    ! Generate statistical report
    call generate_scientific_report()
    
    ! Output result
    call write_analysis_result()
    
contains

subroutine initialize_analysis()
    implicit none
    
    write(*,*) 'FORTRAN: Initializing scientific string analysis...'
    
    ! Initialize all variables with scientific precision
    search_keyword = ''
    content_text = ''
    keyword_upper = ''
    content_upper = ''
    keyword_found = .false.
    
    keyword_length = 0
    content_length = 0
    total_chars = 0
    match_count = 0
    char_position = 0
    search_start = 1
    total_words = 0
    total_lines = 0
    
    match_density = 0.0
    average_position = 0.0
    standard_deviation = 0.0
    position_variance = 0.0
    sum_positions = 0.0
    sum_squares = 0.0
    
    keyword_positions = 0
    
end subroutine initialize_analysis

subroutine read_keyword_data()
    implicit none
    
    ! Read search keyword using Fortran file I/O
    open(newunit=keyword_unit, file='/tmp/fortran_keyword.txt', &
         status='old', action='read', iostat=ios)
    
    if (ios == 0) then
        read(keyword_unit, '(A)', iostat=ios) search_keyword
        close(keyword_unit)
        
        ! Calculate keyword length using intrinsic function
        keyword_length = len_trim(search_keyword)
        
        ! Convert to uppercase for case-insensitive analysis
        keyword_upper = ''
        call to_uppercase(search_keyword, keyword_upper)
        
        write(*,*) 'FORTRAN: Keyword loaded: ', trim(search_keyword)
        write(*,*) 'FORTRAN: Keyword length: ', keyword_length
    else
        write(*,*) 'FORTRAN: Error reading keyword file'
    end if
    
end subroutine read_keyword_data

subroutine read_content_data()
    implicit none
    character(len=1024) :: line_buffer
    integer :: line_count
    
    ! Read content using Fortran file processing
    open(newunit=content_unit, file='/tmp/fortran_content.txt', &
         status='old', action='read', iostat=ios)
    
    if (ios == 0) then
        content_text = ''
        line_count = 0
        
        ! Read file line by line for scientific processing
        do
            read(content_unit, '(A)', iostat=ios) line_buffer
            if (ios /= 0) exit
            
            line_count = line_count + 1
            
            ! Concatenate lines using Fortran string operations
            if (len_trim(content_text) + len_trim(line_buffer) < len(content_text)) then
                content_text = trim(content_text) // ' ' // trim(line_buffer)
            end if
        end do
        
        close(content_unit)
        
        ! Calculate content statistics using intrinsic functions
        content_length = len_trim(content_text)
        total_lines = line_count
        
        ! Convert to uppercase for analysis
        content_upper = ''
        call to_uppercase(content_text, content_upper)
        
        write(*,*) 'FORTRAN: Content loaded, length: ', content_length
        write(*,*) 'FORTRAN: Total lines processed: ', total_lines
    else
        write(*,*) 'FORTRAN: Error reading content file'
    end if
    
end subroutine read_content_data

subroutine to_uppercase(input_string, output_string)
    implicit none
    character(len=*), intent(in) :: input_string
    character(len=*), intent(out) :: output_string
    integer :: i, char_code
    
    output_string = input_string
    
    ! Convert to uppercase using Fortran character operations
    do i = 1, len_trim(input_string)
        char_code = iachar(input_string(i:i))
        if (char_code >= iachar('a') .and. char_code <= iachar('z')) then
            output_string(i:i) = achar(char_code - 32)
        end if
    end do
    
end subroutine to_uppercase

subroutine perform_string_analysis()
    implicit none
    integer :: i, match_position
    
    write(*,*) 'FORTRAN: Performing scientific string analysis...'
    
    ! Reset analysis variables
    match_count = 0
    keyword_found = .false.
    search_start = 1
    
    ! Scientific string search using Fortran intrinsic functions
    do while (search_start <= content_length - keyword_length + 1)
        ! Use INDEX intrinsic function for string searching
        match_position = index(content_upper(search_start:), trim(keyword_upper))
        
        if (match_position > 0) then
            ! Match found - record position for statistical analysis
            match_count = match_count + 1
            keyword_found = .true.
            
            ! Store position for statistical calculations
            if (match_count <= 100) then
                keyword_positions(match_count) = search_start + match_position - 1
            end if
            
            ! Continue search after this match
            search_start = search_start + match_position + keyword_length - 1
        else
            ! No more matches found
            exit
        end if
    end do
    
    ! Calculate word count using scientific analysis
    call count_words_scientific()
    
    write(*,*) 'FORTRAN: String analysis complete'
    write(*,*) 'FORTRAN: Matches found: ', match_count
    
end subroutine perform_string_analysis

subroutine count_words_scientific()
    implicit none
    integer :: i
    logical :: in_word
    
    ! Count words using Fortran logical operations
    total_words = 0
    in_word = .false.
    
    do i = 1, content_length
        if (content_text(i:i) /= ' ' .and. content_text(i:i) /= char(9)) then
            if (.not. in_word) then
                total_words = total_words + 1
                in_word = .true.
            end if
        else
            in_word = .false.
        end if
    end do
    
end subroutine count_words_scientific

subroutine generate_scientific_report()
    implicit none
    integer :: i
    
    write(*,*) 'FORTRAN: Generating scientific analysis report...'
    
    ! Calculate statistical metrics using Fortran arithmetic
    if (content_length > 0) then
        match_density = real(match_count * 100) / real(content_length)
    end if
    
    ! Calculate average position of matches
    if (match_count > 0) then
        sum_positions = 0.0
        do i = 1, match_count
            sum_positions = sum_positions + real(keyword_positions(i))
        end do
        average_position = sum_positions / real(match_count)
        
        ! Calculate standard deviation of match positions
        sum_squares = 0.0
        do i = 1, match_count
            sum_squares = sum_squares + (real(keyword_positions(i)) - average_position)**2
        end do
        
        if (match_count > 1) then
            position_variance = sum_squares / real(match_count - 1)
            standard_deviation = sqrt(position_variance)
        end if
    end if
    
    ! Display comprehensive scientific analysis
    write(*,*) '=== FORTRAN Scientific String Analysis Report ==='
    write(*,*) 'Document Statistics:'
    write(*,*) '  Content Length: ', content_length, ' characters'
    write(*,*) '  Total Words: ', total_words
    write(*,*) '  Total Lines: ', total_lines
    write(*,*) '  Search Keyword: "', trim(search_keyword), '"'
    write(*,*) '  Keyword Length: ', keyword_length, ' characters'
    write(*,*) 'Search Results:'
    write(*,*) '  Matches Found: ', match_count
    write(*,*) '  Match Density: ', match_density, '%'
    if (match_count > 0) then
        write(*,*) '  Average Position: ', average_position
        write(*,*) '  Standard Deviation: ', standard_deviation
        write(*,*) '  Position Variance: ', position_variance
    end if
    write(*,*) 'Final Analysis Result: ', merge('TRUE ', 'FALSE', keyword_found)
    write(*,*) '=== End Scientific Analysis Report ==='
    
end subroutine generate_scientific_report

subroutine write_analysis_result()
    implicit none
    character(len=5) :: result_string
    
    ! Convert logical result to string using Fortran conditional
    result_string = merge('true ', 'false', keyword_found)
    
    ! Write result using Fortran file I/O
    open(newunit=result_unit, file='/tmp/fortran_result.txt', &
         status='replace', action='write', iostat=ios)
    
    if (ios == 0) then
        write(result_unit, '(A)') trim(result_string)
        close(result_unit)
        write(*,*) 'FORTRAN: Result written: ', trim(result_string)
    else
        write(*,*) 'FORTRAN: Error writing result file'
    end if
    
end subroutine write_analysis_result

end program webwords