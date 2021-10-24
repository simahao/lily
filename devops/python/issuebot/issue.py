
class Issue:

    # bind four property
    # defect_desc: ddl is defect_description
    # reason: ddl is primary_reason
    __slots__ = ('__id', '__title', '__defect_desc', '__status', '__severity',  '__reason', '__subsystem')

    # Constructor
    def __init__(self, id, title, defect_desc, status, severity, reason, subsystem):
        self.__id = id
        self.__title = title
        self.__defect_desc = defect_desc
        self.__status = status
        self.__severity = severity
        self.__reason = reason
        self.__subsystem = subsystem

    @property
    def id(self):
        return self.__id

    @id.setter
    def id(self, id):
        self.__id = id

    @property
    def title(self):
        return self.__title

    @title.setter
    def title(self, title):
        self.__title = title

    @property
    def defect_desc(self):
        return self.__defect_desc

    @defect_desc.setter
    def defect_desc(self, defect_desc):
        self.__defect_desc = defect_desc

    @property
    def status(self):
        return self.__status

    @status.setter
    def status(self, status):
        self.__status = status

    @property
    def severity(self):
        return self.__severity

    @severity.setter
    def severity(self, severity):
        self.__severity = severity

    @property
    def reason(self):
        return self.__reason

    @reason.setter
    def reason(self, reason):
        self.__reason = reason

    @property
    def subsystem(self):
        return self.__subsystem

    @subsystem.setter
    def subsystem(self, subsystem):
        self.__subsystem = subsystem

    # toString()
    def __str__(self):
        return "id:%d title:%s defect_description:%s status:%s" % (self.__id, self.__title, self.__defect_desc, self.__status)

    # equals
    def __eq__(self, other):
        return True if self.__id == other.id else False
