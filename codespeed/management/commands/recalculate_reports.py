from django.core.management.base import BaseCommand, CommandError
from optparse import make_option
from codespeed.models import Report


class Command(BaseCommand):
    help = 'Recalculates all reports'

    option_list = BaseCommand.option_list + (
        make_option('--count',
            action="store",
            type="int",
            ),
        )

    def handle(self, *args, **options):
        n = 0
        q = Report.objects.order_by('-revision__date')
        if 'count' in options:
            q = q[:options['count']]
        for report in q:
            self.stdout.write('Recalculating report %s...' % report)
            report.save()
            n += 1
        self.stdout.write('Successfully recalculated %d reports.' % n)
