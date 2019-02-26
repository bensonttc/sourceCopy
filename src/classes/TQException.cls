/**
 *  Generic definition of a custom exception
 */
global class TQException extends Exception {
    
    /**
     *  Store the error code
     */ 
    private Integer errorCode;
    
    /**
     *  Constructor
     */ 
    public TQException(Integer errorCode) {
        setErrorCode(errorCode);
        setMessage('TQException: ' + getErrorCode());
    }
    
    /**
     *  Set the error code
     */
    public void setErrorCode(Integer errorCode) {
        this.errorCode = errorCode;
    }
    
    /**
     *  Get the error code
     */
    public Integer getErrorCode() {
        return this.errorCode;
    }
    
}